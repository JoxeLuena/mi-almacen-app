const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../database');

const app = express();

// 🔑 CONFIGURACIÓN JWT
const JWT_SECRET = process.env.JWT_SECRET || 'molincar_jwt_secret_vercel_2024';

// 🔧 CONFIGURAR CORS
app.use(cors({
    origin: '*', // En producción, especificar dominios exactos
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// =================================
// 📝 FUNCIONES DE LOGS DE ACTIVIDAD
// =================================

async function registrarActividad(usuarioId, accion, descripcion, detalles = null, req = null) {
    const ip = req ? (req.headers['x-forwarded-for'] || req.connection.remoteAddress || 'unknown') : null;
    const userAgent = req ? req.headers['user-agent'] : null;
    
    const query = `
        INSERT INTO logs_actividad (usuario_id, accion, descripcion, detalles, ip_address, user_agent)
        VALUES ($1, $2, $3, $4, $5, $6)
    `;
    
    try {
        await pool.query(query, [
            usuarioId, 
            accion, 
            descripcion, 
            detalles ? JSON.stringify(detalles) : null,
            ip,
            userAgent
        ]);
        console.log(`📝 Log: ${accion} - ${descripcion} (Usuario: ${usuarioId || 'Sistema'})`);
    } catch (err) {
        console.log('❌ Error registrando actividad:', err);
    }
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
        mensaje: 'API MOLINCAR en Vercel + Supabase funcionando!',
        version: '2.0',
        servidor: 'Vercel + PostgreSQL + Supabase',
        entorno: process.env.NODE_ENV || 'production',
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
// 🗄️ ENDPOINTS DE PRODUCTOS
// =================================

app.get('/productos', async (req, res) => {
    try {
        const query = 'SELECT * FROM productos ORDER BY referencia ASC';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.log('Error en consulta productos:', err);
        res.status(500).json({ error: 'Error en la base de datos' });
    }
});

app.post('/productos', async (req, res) => {
    const { referencia, descripcion, precio, stock_actual, uso } = req.body;
    
    if (!referencia || !descripcion) {
        return res.status(400).json({ error: 'Referencia y descripción son obligatorios' });
    }
    
    const query = `
        INSERT INTO productos (referencia, descripcion, precio, stock_actual, uso) 
        VALUES ($1, $2, $3, $4, $5) 
        RETURNING id, referencia, descripcion
    `;
    
    try {
        const result = await pool.query(query, [
            referencia, 
            descripcion, 
            precio || 0, 
            stock_actual || 0,
            uso || 'produccion'
        ]);
        
        await registrarActividad(
            null,
            'CREAR_PRODUCTO', 
            `Creó producto: ${referencia} - ${descripcion}`,
            {
                producto_id: result.rows[0].id,
                referencia: referencia,
                descripcion: descripcion,
                precio: precio || 0,
                stock_inicial: stock_actual || 0,
                uso: uso || 'produccion'
            },
            req
        );
        
        res.json({ 
            ...result.rows[0],
            mensaje: 'Producto creado correctamente' 
        });
    } catch (err) {
        console.log('Error creando producto:', err);
        res.status(500).json({ error: 'Error en la base de datos' });
    }
});

// =================================
// 📋 ENDPOINTS DE ALBARANES
// =================================

app.get('/albaranes', async (req, res) => {
    try {
        const query = 'SELECT * FROM albaranes ORDER BY fecha_creacion DESC';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.log('Error en consulta albaranes:', err);
        res.status(500).json({ error: 'Error en la base de datos' });
    }
});

app.post('/albaranes', async (req, res) => {
    const { cliente, direccion_entrega, observaciones } = req.body;
    
    if (!cliente) {
        return res.status(400).json({ error: 'Cliente es obligatorio' });
    }
    
    try {
        // Generar número de albarán
        const año = new Date().getFullYear();
        
        const countResult = await pool.query(
            'SELECT MAX(CAST(SUBSTRING(numero_albaran, 6) AS INTEGER)) as ultimo_numero FROM albaranes WHERE numero_albaran LIKE $1',
            [`${año}-%`]
        );
        
        const ultimoNumero = countResult.rows[0].ultimo_numero || 0;
        const nuevoNumero = ultimoNumero + 1;
        const numeroAlbaran = `${año}-${nuevoNumero.toString().padStart(4, '0')}`;
        
        const query = `
            INSERT INTO albaranes (numero_albaran, cliente, direccion_entrega, observaciones, estado, fecha_creacion) 
            VALUES ($1, $2, $3, $4, 'pendiente', NOW()) 
            RETURNING id, numero_albaran
        `;
        
        const result = await pool.query(query, [numeroAlbaran, cliente, direccion_entrega, observaciones]);
        
        await registrarActividad(
            null,
            'CREAR_ALBARAN', 
            `Creó albarán ${numeroAlbaran} para cliente: ${cliente}`,
            {
                albaran_id: result.rows[0].id,
                numero_albaran: numeroAlbaran,
                cliente: cliente,
                direccion_entrega: direccion_entrega || null,
                observaciones: observaciones || null
            },
            req
        );
        
        res.json({ 
            ...result.rows[0],
            mensaje: 'Albarán creado correctamente' 
        });
    } catch (err) {
        console.log('Error creando albarán:', err);
        res.status(500).json({ error: 'Error creando albarán' });
    }
});

// =================================
// 👥 ENDPOINTS DE USUARIOS
// =================================

app.get('/usuarios', async (req, res) => {
    try {
        const query = 'SELECT id, nombre, email, rol, activo, created_at FROM usuarios ORDER BY created_at DESC';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.log('Error obteniendo usuarios:', err);
        res.status(500).json({ error: 'Error en la base de datos' });
    }
});

app.post('/usuarios/login', async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Email y contraseña son obligatorios' });
    }
    
    try {
        const query = 'SELECT * FROM usuarios WHERE email = $1 AND activo = true';
        const result = await pool.query(query, [email]);
        
        if (result.rows.length === 0) {
            await registrarActividad(null, 'LOGIN_FALLIDO', `Intento de login fallido para email: ${email}`, { email }, req);
            return res.status(401).json({ error: 'Credenciales inválidas' });
        }
        
        const usuario = result.rows[0];
        const passwordValido = await bcrypt.compare(password, usuario.password_hash);
        
        if (!passwordValido) {
            await registrarActividad(usuario.id, 'LOGIN_FALLIDO', `Password incorrecto para usuario: ${email}`, { email }, req);
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
        
        await registrarActividad(usuario.id, 'LOGIN_EXITOSO', `Usuario logueado exitosamente: ${email}`, { email }, req);
        
        res.json({
            token,
            usuario: {
                id: usuario.id,
                nombre: usuario.nombre,
                email: usuario.email,
                rol: usuario.rol
            }
        });
    } catch (err) {
        console.log('Error en login:', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 🚀 SETUP: Crear primer administrador
app.post('/setup/primer-admin', async (req, res) => {
    const { nombre, email, password } = req.body;
    
    if (!nombre || !email || !password) {
        return res.status(400).json({ error: 'Nombre, email y contraseña son obligatorios' });
    }
    
    if (password.length < 6) {
        return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
    }
    
    try {
        // Verificar si ya hay usuarios
        const checkResult = await pool.query('SELECT COUNT(*) as total FROM usuarios');
        const totalUsuarios = parseInt(checkResult.rows[0].total);
        
        if (totalUsuarios > 0) {
            return res.status(403).json({ 
                error: 'Ya existen usuarios en el sistema. Use el login normal.'
            });
        }
        
        // Verificar email único
        const emailResult = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email]);
        if (emailResult.rows.length > 0) {
            return res.status(409).json({ error: 'El email ya está registrado' });
        }
        
        // Crear usuario
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        
        const query = `
            INSERT INTO usuarios (nombre, email, password_hash, rol, activo, created_at)
            VALUES ($1, $2, $3, 'admin', true, NOW())
            RETURNING id, nombre, email, rol
        `;
        
        const result = await pool.query(query, [nombre, email, passwordHash]);
        
        await registrarActividad(
            result.rows[0].id,
            'CREAR_PRIMER_ADMIN', 
            `Primer administrador creado: ${nombre} (${email})`,
            {
                usuario_id: result.rows[0].id,
                nombre: nombre,
                email: email
            },
            req
        );
        
        res.status(201).json({
            ...result.rows[0],
            mensaje: 'Primer administrador creado correctamente'
        });
    } catch (err) {
        console.log('Error creando primer admin:', err);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// =================================
// 📝 ENDPOINTS DE LOGS
// =================================

app.get('/logs/actividad', async (req, res) => {
    const { limit = 50, offset = 0 } = req.query;
    
    try {
        const query = `
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
            ORDER BY la.created_at DESC 
            LIMIT $1 OFFSET $2
        `;
        
        const result = await pool.query(query, [parseInt(limit), parseInt(offset)]);
        
        const logs = result.rows.map(log => ({
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
    } catch (err) {
        console.log('❌ Error obteniendo logs:', err);
        res.status(500).json({ error: 'Error en la base de datos' });
    }
});

// =================================
// 🚀 EXPORTAR PARA VERCEL
// =================================

// Para desarrollo local
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
    });
}

// Para Vercel (serverless)
module.exports = app;