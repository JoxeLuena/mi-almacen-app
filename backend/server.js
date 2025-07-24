const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();

// 🔧 PUERTO DINÁMICO PARA SERED (Passenger asigna automáticamente)
// const PORT = process.env.PORT || 3000;
const PORT = process.env.PORT || 3000;
// Importar la conexión a la base de datos
const db = require('./database');

// 🔑 CLAVE JWT DESDE VARIABLES DE ENTORNO
const JWT_SECRET = process.env.JWT_SECRET || 'tu_clave_secreta_muy_segura_molincar_2024';

// 🔧 CONFIGURAR CORS PARA PRODUCCIÓN
app.use(cors({
    origin: process.env.NODE_ENV === 'production' 
        ? ['https://guitarradeluena.site', 'https://molincar.guitarradeluena.site']
        : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware para parsear JSON
app.use(express.json());

// =================================
// 📝 FUNCIONES DE LOGS DE ACTIVIDAD
// =================================

function registrarActividad(usuarioId, accion, descripcion, detalles = null, req = null) {
    const ip = req ? (req.headers['x-forwarded-for'] || req.connection.remoteAddress || 'unknown') : null;
    const userAgent = req ? req.headers['user-agent'] : null;
    
    const query = `
        INSERT INTO logs_actividad (usuario_id, accion, descripcion, detalles, ip_address, user_agent)
        VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    db.query(query, [
        usuarioId, 
        accion, 
        descripcion, 
        detalles ? JSON.stringify(detalles) : null,
        ip,
        userAgent
    ], (err) => {
        if (err) {
            console.log('❌ Error registrando actividad:', err);
        } else {
            console.log(`📝 Log: ${accion} - ${descripcion} (Usuario: ${usuarioId || 'Sistema'})`);
        }
    });
}

function registrarError(error, descripcion, usuarioId = null, req = null) {
    registrarActividad(
        usuarioId,
        'ERROR',
        `Error: ${descripcion}`,
        {
            error_message: error.message,
            error_stack: error.stack,
            timestamp: new Date().toISOString()
        },
        req
    );
}

// 🛡️ MIDDLEWARE: Verificar token JWT
const verificarToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado' });
    }
    
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Token inválido' });
        }
        req.usuario = decoded;
        next();
    });
};

// 🛣️ RUTA DE PRUEBA
app.get('/', (req, res) => {
    res.json({ 
        mensaje: 'API del Sistema de Gestión de Almacén MOLINCAR funcionando!',
        version: '2.0',
        servidor: 'Node.js + Express + MySQL (Sered Hosting)',
        entorno: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString(),
        endpoints: [
            '/productos - Gestión de productos',
            '/albaranes - Gestión de albaranes',
            '/usuarios - Gestión de usuarios',
            '/usuarios/login - Autenticación',
            '/setup/primer-admin - Configuración inicial',
            '/logs/actividad - Logs del sistema'
        ]
    });
});

// =================================
// 📝 ENDPOINTS DE LOGS DE ACTIVIDAD
// =================================

app.get('/logs/actividad', (req, res) => {
    const { limit = 50, offset = 0, usuario_id, accion, fecha_desde, fecha_hasta } = req.query;
    
    let query = `
        SELECT 
            la.id,
            la.usuario_id,
            la.accion,
            la.descripcion,
            la.detalles,
            la.ip_address,
            la.created_at,
            u.nombre as usuario_nombre,
            u.email as usuario_email
        FROM logs_actividad la
        LEFT JOIN usuarios u ON la.usuario_id = u.id
        WHERE 1=1
    `;
    
    const params = [];
    
    if (usuario_id) {
        query += ' AND la.usuario_id = ?';
        params.push(usuario_id);
    }
    
    if (accion) {
        query += ' AND la.accion = ?';
        params.push(accion);
    }
    
    if (fecha_desde) {
        query += ' AND la.created_at >= ?';
        params.push(fecha_desde);
    }
    
    if (fecha_hasta) {
        query += ' AND la.created_at <= ?';
        params.push(fecha_hasta);
    }
    
    query += ' ORDER BY la.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));
    
    db.query(query, params, (err, results) => {
        if (err) {
            console.log('❌ Error obteniendo logs:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            const logs = results.map(log => ({
                ...log,
                detalles: log.detalles ? JSON.parse(log.detalles) : null
            }));
            
            res.json({
                exito: true,
                logs: logs,
                total: logs.length,
                limit: parseInt(limit),
                offset: parseInt(offset)
            });
        }
    });
});

// =================================
// 🗄️ ENDPOINTS DE PRODUCTOS
// =================================

app.get('/productos', (req, res) => {
    const query = 'SELECT * FROM productos ORDER BY referencia ASC';
    
    db.query(query, (err, results) => {
        if (err) {
            console.log('Error en consulta productos:', err);
            registrarError(err, 'Error obteniendo productos', null, req);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

app.post('/productos', (req, res) => {
    const { referencia, descripcion, precio, stock_actual } = req.body;
    
    if (!referencia || !descripcion) {
        return res.status(400).json({ error: 'Referencia y descripción son obligatorios' });
    }
    
    const query = `
        INSERT INTO productos (referencia, descripcion, precio, stock_actual) 
        VALUES (?, ?, ?, ?)
    `;
    
    db.query(query, [referencia, descripcion, precio || 0, stock_actual || 0], (err, result) => {
        if (err) {
            console.log('Error creando producto:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            registrarActividad(
                null,
                'CREAR_PRODUCTO', 
                `Creó producto: ${referencia} - ${descripcion}`,
                {
                    producto_id: result.insertId,
                    referencia: referencia,
                    descripcion: descripcion,
                    precio: precio || 0,
                    stock_inicial: stock_actual || 0
                },
                req
            );
            
            res.json({ 
                id: result.insertId,
                referencia,
                descripcion,
                mensaje: 'Producto creado correctamente' 
            });
        }
    });
});

// =================================
// 📋 ENDPOINTS DE ALBARANES
// =================================

app.get('/albaranes', (req, res) => {
    const query = 'SELECT * FROM albaranes ORDER BY fecha_creacion DESC';
    
    db.query(query, (err, results) => {
        if (err) {
            console.log('Error en consulta albaranes:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

app.post('/albaranes', (req, res) => {
    const { cliente, direccion_entrega, observaciones } = req.body;
    
    if (!cliente) {
        return res.status(400).json({ error: 'Cliente es obligatorio' });
    }
    
    const año = new Date().getFullYear();
    
    db.query(
        'SELECT MAX(CAST(SUBSTRING(numero_albaran, 6) AS UNSIGNED)) as ultimo_numero FROM albaranes WHERE numero_albaran LIKE ?',
        [`${año}-%`],
        (err, countResult) => {
            if (err) {
                console.log('Error obteniendo contador:', err);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            const ultimoNumero = countResult[0].ultimo_numero || 0;
            const nuevoNumero = ultimoNumero + 1;
            const numeroAlbaran = `${año}-${nuevoNumero.toString().padStart(4, '0')}`;
            
            const query = `
                INSERT INTO albaranes (numero_albaran, cliente, direccion_entrega, observaciones, estado, fecha_creacion) 
                VALUES (?, ?, ?, ?, 'pendiente', NOW())
            `;
            
            db.query(query, [numeroAlbaran, cliente, direccion_entrega, observaciones], (err, results) => {
                if (err) {
                    console.log('Error creando albarán:', err);
                    registrarError(err, 'Error creando albarán', null, req);
                    res.status(500).json({ error: 'Error creando albarán' });
                } else {
                    registrarActividad(
                        null,
                        'CREAR_ALBARAN', 
                        `Creó albarán ${numeroAlbaran} para cliente: ${cliente}`,
                        {
                            albaran_id: results.insertId,
                            numero_albaran: numeroAlbaran,
                            cliente: cliente,
                            direccion_entrega: direccion_entrega || null,
                            observaciones: observaciones || null
                        },
                        req
                    );
                    
                    res.json({ 
                        id: results.insertId,
                        numero_albaran: numeroAlbaran,
                        mensaje: 'Albarán creado correctamente' 
                    });
                }
            });
        }
    );
});

// =================================
// 👥 ENDPOINTS DE USUARIOS
// =================================

app.get('/usuarios', (req, res) => {
    const query = 'SELECT id, nombre, email, rol, activo, created_at FROM usuarios ORDER BY created_at DESC';
    
    db.query(query, (err, results) => {
        if (err) {
            console.log('Error obteniendo usuarios:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

app.post('/usuarios/login', (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Email y contraseña son obligatorios' });
    }
    
    const query = 'SELECT * FROM usuarios WHERE email = ? AND activo = 1';
    
    db.query(query, [email], async (err, results) => {
        if (err) {
            console.log('Error en login:', err);
            return res.status(500).json({ error: 'Error en la base de datos' });
        }
        
        if (results.length === 0) {
            registrarActividad(null, 'LOGIN_FALLIDO', `Intento de login fallido para email: ${email}`, { email }, req);
            return res.status(401).json({ error: 'Credenciales inválidas' });
        }
        
        const usuario = results[0];
        
        try {
            const passwordValido = await bcrypt.compare(password, usuario.password);
            
            if (!passwordValido) {
                registrarActividad(usuario.id, 'LOGIN_FALLIDO', `Password incorrecto para usuario: ${email}`, { email }, req);
                return res.status(401).json({ error: 'Credenciales inválidas' });
            }
            
            const token = jwt.sign(
                { 
                    id: usuario.id, 
                    email: usuario.email, 
                    rol: usuario.rol 
                },
                JWT_SECRET,
                { expiresIn: '24h' }
            );
            
            registrarActividad(usuario.id, 'LOGIN_EXITOSO', `Usuario logueado exitosamente: ${email}`, { email }, req);
            
            res.json({
                token,
                usuario: {
                    id: usuario.id,
                    nombre: usuario.nombre,
                    email: usuario.email,
                    rol: usuario.rol
                }
            });
            
        } catch (error) {
            console.log('Error verificando password:', error);
            res.status(500).json({ error: 'Error interno del servidor' });
        }
    });
});

// =================================
// 🚀 INICIAR SERVIDOR
// =================================

app.listen(PORT, () => {
    console.log(`🚀 Servidor MOLINCAR corriendo en puerto ${PORT}`);
    console.log(`🌐 Entorno: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📋 Dominio: https://molincar.guitarradeluena.site`);
    console.log(`=======================================`);
    console.log(`✅ Sistema MOLINCAR listo para funcionar`);
    
    registrarActividad(
        null,
        'SERVIDOR_INICIADO',
        `Servidor iniciado en puerto ${PORT}`,
        {
            puerto: PORT,
            entorno: process.env.NODE_ENV || 'development',
            timestamp: new Date().toISOString()
        }
    );
});

module.exports = app;