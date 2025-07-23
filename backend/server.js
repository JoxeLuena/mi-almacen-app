const express = require('express');        // 📦 Importar Express
const cors = require('cors');              // 🌐 Importar CORS
const bcrypt = require('bcrypt');           // 🔐 Para encriptar contraseñas
const jwt = require('jsonwebtoken');        // 🎫 Para tokens de autenticación

const app = express();                     // 🏗️ Crear nuestra aplicación web
const PORT = 3000;                         // 🚪 Puerto donde escucha el servidor

// Importar la conexión a la base de datos
const db = require('./database');          // 🗄️ Conexión a MySQL

// 🔑 CONFIGURACIÓN: Clave secreta JWT (CAMBIAR EN PRODUCCIÓN)
const JWT_SECRET = 'tu_clave_secreta_muy_segura_molincar_2024';

// 🔧 CONFIGURAR CORS: Permitir peticiones desde el navegador
app.use(cors({
    origin: '*',                           // 🌍 Permitir peticiones desde cualquier origen (desarrollo)
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // 📋 Métodos HTTP permitidos
    allowedHeaders: ['Content-Type', 'Authorization'] // 📨 Headers permitidos
}));

// Middleware para parsear JSON
app.use(express.json());                   // 🔧 Convertir datos recibidos a JSON automáticamente

// =================================
// 📝 FUNCIONES DE LOGS DE ACTIVIDAD
// =================================

// 📝 FUNCIÓN AUXILIAR: Registrar actividad en la base de datos
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

// 🚨 FUNCIÓN DE LOG PARA ERRORES
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
    const token = req.headers['authorization']?.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado' });
    }
    
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Token inválido' });
        }
        req.usuario = decoded; // Guardamos datos del usuario en el request
        next();
    });
};

// 🛣️ RUTA DE PRUEBA: Verificar que la API funciona
app.get('/', (req, res) => {
    res.json({ 
        mensaje: 'API del Sistema de Gestión de Almacén MOLINCAR funcionando!',
        version: '2.0',
        servidor: 'Node.js + Express + MySQL',
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

// 📝 RUTA: Obtener logs de actividad (SIN autenticación por ahora)
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
    
    // 🔍 Filtros opcionales
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
            // 🔄 Parsear detalles JSON
            const logs = results.map(log => ({
                ...log,
                detalles: log.detalles ? JSON.parse(log.detalles) : null
            }));
            
            console.log(`📋 Enviando ${logs.length} logs al frontend`);
            res.json(logs);
        }
    });
});

// 📊 RUTA: Estadísticas de actividad (SIN autenticación por ahora)
app.get('/logs/estadisticas', (req, res) => {
    const query = `
        SELECT 
            COUNT(*) as total_actividades,
            COUNT(DISTINCT usuario_id) as usuarios_activos,
            COUNT(CASE WHEN accion = 'LOGIN' THEN 1 END) as total_logins,
            COUNT(CASE WHEN accion = 'CREAR_USUARIO' THEN 1 END) as usuarios_creados,
            COUNT(CASE WHEN accion = 'CREAR_ALBARAN' THEN 1 END) as albaranes_creados,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN 1 END) as actividades_24h,
            COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as actividades_7d
        FROM logs_actividad
    `;
    
    db.query(query, (err, results) => {
        if (err) {
            console.log('❌ Error obteniendo estadísticas logs:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            console.log('📊 Estadísticas de logs enviadas');
            res.json(results[0]);
        }
    });
});

// 🔍 RUTA: Buscar en logs (SIN autenticación por ahora)
app.get('/logs/buscar', (req, res) => {
    const { q, limit = 20 } = req.query;
    
    if (!q || q.length < 2) {
        return res.json([]);
    }
    
    const query = `
        SELECT 
            la.id,
            la.usuario_id,
            la.accion,
            la.descripcion,
            la.detalles,
            la.created_at,
            u.nombre as usuario_nombre,
            u.email as usuario_email
        FROM logs_actividad la
        LEFT JOIN usuarios u ON la.usuario_id = u.id
        WHERE la.descripcion LIKE ? 
           OR la.accion LIKE ? 
           OR u.nombre LIKE ?
           OR u.email LIKE ?
        ORDER BY la.created_at DESC
        LIMIT ?
    `;
    
    const searchTerm = `%${q}%`;
    
    db.query(query, [searchTerm, searchTerm, searchTerm, searchTerm, parseInt(limit)], (err, results) => {
        if (err) {
            console.log('❌ Error buscando en logs:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            const logs = results.map(log => ({
                ...log,
                detalles: log.detalles ? JSON.parse(log.detalles) : null
            }));
            
            res.json(logs);
        }
    });
});

// =================================
// 🚀 ENDPOINTS DE CONFIGURACIÓN INICIAL
// =================================

// 🚀 RUTA PÚBLICA: Crear primer administrador (solo si no hay usuarios)
app.post('/setup/primer-admin', async (req, res) => {
    const { nombre, email, password } = req.body;
    
    // Validaciones
    if (!nombre || !email || !password) {
        return res.status(400).json({ error: 'Nombre, email y contraseña son obligatorios' });
    }
    
    if (password.length < 6) {
        return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
    }
    
    if (!email.includes('@')) {
        return res.status(400).json({ error: 'Email inválido' });
    }
    
    try {
        // Verificar si ya hay usuarios en el sistema
        const checkUsersQuery = 'SELECT COUNT(*) as total FROM usuarios';
        
        db.query(checkUsersQuery, async (err, results) => {
            if (err) {
                console.log('Error verificando usuarios:', err);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            const totalUsuarios = results[0].total;
            
            if (totalUsuarios > 0) {
                return res.status(403).json({ 
                    error: 'Ya existen usuarios en el sistema. Use el login normal.' 
                });
            }
            
            try {
                // Encriptar contraseña
                const saltRounds = 10;
                const passwordHash = await bcrypt.hash(password, saltRounds);
                
                // Crear primer administrador
                const insertQuery = `
                    INSERT INTO usuarios (nombre, email, password_hash, rol, activo, created_at)
                    VALUES (?, ?, ?, 'administrador', 1, NOW())
                `;
                
                db.query(insertQuery, [nombre, email, passwordHash], (err, result) => {
                    if (err) {
                        console.log('Error creando primer admin:', err);
                        res.status(500).json({ error: 'Error creando administrador' });
                    } else {
                        // ✅ REGISTRAR LOG
                        registrarActividad(
                            result.insertId,
                            'CREAR_PRIMER_ADMIN',
                            `Creado primer administrador: ${nombre}`,
                            {
                                admin_id: result.insertId,
                                admin_nombre: nombre,
                                admin_email: email
                            },
                            req
                        );
                        
                        res.status(201).json({
                            id: result.insertId,
                            nombre,
                            email,
                            rol: 'administrador',
                            mensaje: 'Primer administrador creado correctamente. Ya puedes hacer login.'
                        });
                    }
                });
            } catch (hashError) {
                console.log('Error encriptando contraseña:', hashError);
                res.status(500).json({ error: 'Error interno del servidor' });
            }
        });
    } catch (error) {
        console.log('Error en setup primer admin:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// =================================
// 👥 ENDPOINTS DE AUTENTICACIÓN
// =================================

// 🔐 RUTA: Login de usuario
app.post('/usuarios/login', async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Email y contraseña son obligatorios' });
    }
    
    try {
        // Buscar usuario por email
        const query = 'SELECT * FROM usuarios WHERE email = ? AND activo = 1';
        
        db.query(query, [email], async (err, results) => {
            if (err) {
                console.log('Error en login:', err);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            if (results.length === 0) {
                return res.status(401).json({ error: 'Credenciales inválidas' });
            }
            
            const usuario = results[0];
            
            // Verificar contraseña
            const passwordValida = await bcrypt.compare(password, usuario.password_hash);
            
            if (!passwordValida) {
                return res.status(401).json({ error: 'Credenciales inválidas' });
            }
            
            // Actualizar último acceso
            db.query('UPDATE usuarios SET ultimo_acceso = NOW() WHERE id = ?', [usuario.id]);
            
            // Generar token JWT
            const token = jwt.sign(
                { 
                    id: usuario.id, 
                    email: usuario.email, 
                    rol: usuario.rol,
                    nombre: usuario.nombre
                },
                JWT_SECRET,
                { expiresIn: '24h' }
            );
            
            // ✅ REGISTRAR LOG DE LOGIN
            registrarActividad(
                usuario.id, 
                'LOGIN', 
                `Usuario ${usuario.nombre} inició sesión`, 
                {
                    email: usuario.email,
                    rol: usuario.rol,
                    metodo: 'email_password'
                }, 
                req
            );
            
            // Responder con datos del usuario (sin contraseña) y token
            const { password_hash, ...usuarioSinPassword } = usuario;
            
            res.json({
                usuario: usuarioSinPassword,
                token,
                mensaje: 'Login exitoso'
            });
        });
    } catch (error) {
        console.log('Error en login:', error);
        registrarError(error, 'Error en login', null, req);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 🔑 RUTA: Verificar token (para mantener sesión)
app.get('/usuarios/verificar-token', verificarToken, (req, res) => {
    // Si llegamos aquí, el token es válido
    res.json({
        valido: true,
        usuario: req.usuario,
        mensaje: 'Token válido'
    });
});

// =================================
// 👥 ENDPOINTS DE USUARIOS (REQUIEREN AUTENTICACIÓN)
// =================================

// 👥 RUTA: Obtener todos los usuarios
app.get('/usuarios', verificarToken, (req, res) => {
    const query = `
        SELECT 
            id, nombre, email, rol, activo, 
            DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
            DATE_FORMAT(ultimo_acceso, '%Y-%m-%d %H:%i:%s') as ultimo_acceso
        FROM usuarios 
        ORDER BY nombre ASC
    `;
    
    db.query(query, (err, results) => {
        if (err) {
            console.log('Error obteniendo usuarios:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

// 👤 RUTA: Obtener usuario por ID
app.get('/usuarios/:id', verificarToken, (req, res) => {
    const usuarioId = req.params.id;
    
    const query = `
        SELECT 
            id, nombre, email, rol, activo, 
            DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
            DATE_FORMAT(ultimo_acceso, '%Y-%m-%d %H:%i:%s') as ultimo_acceso
        FROM usuarios 
        WHERE id = ?
    `;
    
    db.query(query, [usuarioId], (err, results) => {
        if (err) {
            console.log('Error obteniendo usuario:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else if (results.length === 0) {
            res.status(404).json({ error: 'Usuario no encontrado' });
        } else {
            res.json(results[0]);
        }
    });
});

// ➕ RUTA: Crear nuevo usuario
app.post('/usuarios', verificarToken, async (req, res) => {
    const { nombre, email, password, rol } = req.body;
    
    // Validaciones
    if (!nombre || !email || !password) {
        return res.status(400).json({ error: 'Nombre, email y contraseña son obligatorios' });
    }
    
    if (password.length < 6) {
        return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
    }
    
    if (!email.includes('@')) {
        return res.status(400).json({ error: 'Email inválido' });
    }
    
    try {
        // Verificar si el email ya existe
        const checkQuery = 'SELECT id FROM usuarios WHERE email = ?';
        
        db.query(checkQuery, [email], async (err, existing) => {
            if (err) {
                console.log('Error verificando email:', err);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            if (existing.length > 0) {
                return res.status(409).json({ error: 'El email ya está registrado' });
            }
            
            // Encriptar contraseña
            const saltRounds = 10;
            const passwordHash = await bcrypt.hash(password, saltRounds);
            
            // Crear usuario
            const insertQuery = `
                INSERT INTO usuarios (nombre, email, password_hash, rol, activo, created_at)
                VALUES (?, ?, ?, ?, 1, NOW())
            `;
            
            db.query(insertQuery, [nombre, email, passwordHash, rol || 'usuario'], (err, result) => {
                if (err) {
                    console.log('Error creando usuario:', err);
                    registrarError(err, 'Error creando usuario', req.usuario?.id, req);
                    res.status(500).json({ error: 'Error creando usuario' });
                } else {
                    // ✅ REGISTRAR LOG DE CREACIÓN DE USUARIO
                    registrarActividad(
                        req.usuario?.id,
                        'CREAR_USUARIO', 
                        `Creó usuario: ${nombre} (${email})`,
                        {
                            usuario_creado_id: result.insertId,
                            usuario_creado_nombre: nombre,
                            usuario_creado_email: email,
                            usuario_creado_rol: rol || 'usuario',
                            creado_por: req.usuario?.nombre || 'Sistema'
                        },
                        req
                    );
                    
                    res.status(201).json({
                        id: result.insertId,
                        nombre,
                        email,
                        rol: rol || 'usuario',
                        mensaje: 'Usuario creado correctamente'
                    });
                }
            });
        });
    } catch (error) {
        console.log('Error en creación de usuario:', error);
        registrarError(error, 'Error en creación de usuario', req.usuario?.id, req);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// ✏️ RUTA: Actualizar usuario
app.put('/usuarios/:id', verificarToken, async (req, res) => {
    const usuarioId = req.params.id;
    const { nombre, email, rol, password } = req.body;
    
    if (!nombre || !email) {
        return res.status(400).json({ error: 'Nombre y email son obligatorios' });
    }
    
    try {
        let query = 'UPDATE usuarios SET nombre = ?, email = ?, rol = ?, updated_at = NOW() WHERE id = ?';
        let params = [nombre, email, rol || 'usuario', usuarioId];
        
        // Si se proporciona nueva contraseña, encriptarla
        if (password && password.length >= 6) {
            const saltRounds = 10;
            const passwordHash = await bcrypt.hash(password, saltRounds);
            query = 'UPDATE usuarios SET nombre = ?, email = ?, rol = ?, password_hash = ?, updated_at = NOW() WHERE id = ?';
            params = [nombre, email, rol || 'usuario', passwordHash, usuarioId];
        }
        
        db.query(query, params, (err, result) => {
            if (err) {
                console.log('Error actualizando usuario:', err);
                registrarError(err, 'Error actualizando usuario', req.usuario?.id, req);
                res.status(500).json({ error: 'Error actualizando usuario' });
            } else if (result.affectedRows === 0) {
                res.status(404).json({ error: 'Usuario no encontrado' });
            } else {
                // ✅ REGISTRAR LOG DE ACTUALIZACIÓN
                registrarActividad(
                    req.usuario?.id,
                    'ACTUALIZAR_USUARIO',
                    `Actualizó usuario ID ${usuarioId}`,
                    {
                        usuario_actualizado_id: usuarioId,
                        campos_actualizados: Object.keys(req.body),
                        actualizado_por: req.usuario?.nombre
                    },
                    req
                );
                
                res.json({ mensaje: 'Usuario actualizado correctamente' });
            }
        });
    } catch (error) {
        console.log('Error en actualización:', error);
        registrarError(error, 'Error en actualización de usuario', req.usuario?.id, req);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// 🔑 RUTA: Cambiar contraseña del usuario actual
app.put('/usuarios/cambiar-password', verificarToken, async (req, res) => {
    const { passwordActual, passwordNuevo } = req.body;
    const usuarioId = req.usuario.id; // Del token JWT
    
    // Validaciones
    if (!passwordActual || !passwordNuevo) {
        return res.status(400).json({ 
            error: 'Contraseña actual y nueva son obligatorias' 
        });
    }
    
    if (passwordNuevo.length < 6) {
        return res.status(400).json({ 
            error: 'La nueva contraseña debe tener al menos 6 caracteres' 
        });
    }
    
    try {
        // Obtener usuario actual
        const getUserQuery = 'SELECT password_hash FROM usuarios WHERE id = ?';
        
        db.query(getUserQuery, [usuarioId], async (err, results) => {
            if (err) {
                console.log('Error obteniendo usuario para cambio password:', err);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            if (results.length === 0) {
                return res.status(404).json({ error: 'Usuario no encontrado' });
            }
            
            const usuario = results[0];
            
            try {
                // Verificar contraseña actual
                const passwordActualValida = await bcrypt.compare(passwordActual, usuario.password_hash);
                
                if (!passwordActualValida) {
                    return res.status(400).json({ error: 'La contraseña actual es incorrecta' });
                }
                
                // Verificar que la nueva no sea igual a la actual
                const nuevaIgualActual = await bcrypt.compare(passwordNuevo, usuario.password_hash);
                if (nuevaIgualActual) {
                    return res.status(400).json({ error: 'La nueva contraseña debe ser diferente a la actual' });
                }
                
                // Encriptar nueva contraseña
                const saltRounds = 10;
                const nuevoPasswordHash = await bcrypt.hash(passwordNuevo, saltRounds);
                
                // Actualizar contraseña
                const updateQuery = `
                    UPDATE usuarios 
                    SET password_hash = ?, updated_at = NOW() 
                    WHERE id = ?
                `;
                
                db.query(updateQuery, [nuevoPasswordHash, usuarioId], (err, result) => {
                    if (err) {
                        console.log('Error actualizando contraseña:', err);
                        res.status(500).json({ error: 'Error actualizando contraseña' });
                    } else {
                        // ✅ REGISTRAR LOG DE CAMBIO DE CONTRASEÑA
                        registrarActividad(
                            usuarioId, 
                            'CAMBIO_PASSWORD', 
                            `Usuario cambió su contraseña`,
                            {
                                usuario_nombre: req.usuario?.nombre || 'Desconocido',
                                timestamp: new Date().toISOString(),
                                metodo: 'formulario_cambio'
                            },
                            req
                        );
                        
                        console.log(`✅ Contraseña cambiada para usuario ${usuarioId}`);
                        res.json({ 
                            mensaje: 'Contraseña actualizada correctamente' 
                        });
                    }
                });
                
            } catch (hashError) {
                console.log('Error de encriptación:', hashError);
                res.status(500).json({ error: 'Error interno del servidor' });
            }
        });
        
    } catch (error) {
        console.log('Error en cambio de contraseña:', error);
        registrarError(error, 'Error en cambio de contraseña', usuarioId, req);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// =================================
// 📦 ENDPOINTS DE PRODUCTOS
// =================================

// 🛣️ RUTA: Obtener todos los productos
app.get('/productos', (req, res) => {
    db.query('SELECT * FROM productos ORDER BY referencia ASC', (err, results) => {
        if (err) {
            console.log('Error en consulta productos:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

// 🔍 RUTA: Buscar productos (para autocompletado)
app.get('/productos/buscar', (req, res) => {
    const query = req.query.q || '';
    const sqlQuery = `
        SELECT * FROM productos 
        WHERE referencia LIKE ? OR descripcion LIKE ? 
        ORDER BY referencia ASC 
        LIMIT 50
    `;
    const searchTerm = `%${query}%`;
    
    db.query(sqlQuery, [searchTerm, searchTerm], (err, results) => {
        if (err) {
            console.log('Error buscando productos:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

// ➕ RUTA: Crear nuevo producto
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
            // ✅ REGISTRAR LOG DE CREACIÓN DE PRODUCTO
            registrarActividad(
                null, // Cambiar por req.usuario?.id cuando implementes autenticación completa
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

// 📋 RUTA: Obtener todos los albaranes
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

// ➕ RUTA: Crear un nuevo albarán
app.post('/albaranes', (req, res) => {
    const { cliente, direccion_entrega, observaciones } = req.body;
    
    if (!cliente) {
        return res.status(400).json({ error: 'Cliente es obligatorio' });
    }
    
    // Generar número de albarán simple (año + contador)
    const año = new Date().getFullYear();
    
    // Primero obtener el último número del año actual
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
            
            // Crear el albarán
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
                    // ✅ REGISTRAR LOG DE CREACIÓN DE ALBARÁN
                    registrarActividad(
                        null, // Cambiar por req.usuario?.id cuando implementes autenticación completa
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

// 📦 RUTA: Obtener productos de un albarán específico
app.get('/albaranes/:id/productos', (req, res) => {
    const albaranId = req.params.id;
    const query = `
        SELECT 
            al.id,
            al.cantidad,
            al.observaciones,
            p.id as producto_id,
            p.referencia,
            p.descripcion,
            p.precio
        FROM albaran_lineas al
        JOIN productos p ON al.producto_id = p.id
        WHERE al.albaran_id = ?
        ORDER BY p.referencia ASC
    `;
    
    db.query(query, [albaranId], (err, results) => {
        if (err) {
            console.log('Error obteniendo productos del albarán:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

// ➕ RUTA: Añadir producto a un albarán
app.post('/albaranes/:id/productos', (req, res) => {
    const albaranId = req.params.id;
    const { producto_id, cantidad, observaciones } = req.body;
    
    if (!producto_id || !cantidad) {
        return res.status(400).json({ error: 'producto_id y cantidad son obligatorios' });
    }
    
    const query = `
        INSERT INTO albaran_lineas (albaran_id, producto_id, cantidad, observaciones)
        VALUES (?, ?, ?, ?)
    `;
    
    db.query(query, [albaranId, producto_id, cantidad, observaciones], (err, result) => {
        if (err) {
            console.log('Error añadiendo producto al albarán:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json({ 
                id: result.insertId,
                mensaje: 'Producto añadido correctamente' 
            });
        }
    });
});

// ✏️ RUTA: Actualizar albarán
app.put('/albaranes/:id', (req, res) => {
    const albaranId = req.params.id;
    const { cliente, direccion_entrega, observaciones } = req.body;
    
    if (!cliente) {
        return res.status(400).json({ error: 'Cliente es obligatorio' });
    }
    
    const query = `
        UPDATE albaranes 
        SET cliente = ?, direccion_entrega = ?, observaciones = ?
        WHERE id = ?
    `;
    
    db.query(query, [cliente, direccion_entrega, observaciones, albaranId], (err, result) => {
        if (err) {
            console.log('Error actualizando albarán:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else if (result.affectedRows === 0) {
            res.status(404).json({ error: 'Albarán no encontrado' });
        } else {
            // ✅ REGISTRAR LOG DE ACTUALIZACIÓN DE ALBARÁN
            registrarActividad(
                null, // Cambiar por req.usuario?.id cuando implementes autenticación completa
                'ACTUALIZAR_ALBARAN', 
                `Actualizó albarán ID ${albaranId}`,
                {
                    albaran_id: albaranId,
                    campos_actualizados: Object.keys(req.body),
                    valores_nuevos: req.body
                },
                req
            );
            
            res.json({ mensaje: 'Albarán actualizado correctamente' });
        }
    });
});

// 📤 RUTA: Marcar albarán como enviado
app.put('/albaranes/:id/enviar', (req, res) => {
    const albaranId = req.params.id;
    
    const query = `
        UPDATE albaranes 
        SET estado = 'enviado', fecha_envio = NOW()
        WHERE id = ?
    `;
    
    db.query(query, [albaranId], (err, result) => {
        if (err) {
            console.log('Error marcando como enviado:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else if (result.affectedRows === 0) {
            res.status(404).json({ error: 'Albarán no encontrado' });
        } else {
            // ✅ REGISTRAR LOG DE ENVÍO
            registrarActividad(
                null,
                'ENVIAR_ALBARAN', 
                `Marcó albarán ID ${albaranId} como enviado`,
                {
                    albaran_id: albaranId,
                    estado_anterior: 'pendiente',
                    estado_nuevo: 'enviado'
                },
                req
            );
            
            res.json({ mensaje: 'Albarán marcado como enviado' });
        }
    });
});

// 📦 RUTA: Marcar albarán como entregado
app.put('/albaranes/:id/entregar', (req, res) => {
    const albaranId = req.params.id;
    const { receptor_confirma } = req.body;
    
    const query = `
        UPDATE albaranes 
        SET estado = 'entregado', fecha_entrega = NOW(), receptor_confirma = ?
        WHERE id = ?
    `;
    
    db.query(query, [receptor_confirma || null, albaranId], (err, result) => {
        if (err) {
            console.log('Error marcando como entregado:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else if (result.affectedRows === 0) {
            res.status(404).json({ error: 'Albarán no encontrado' });
        } else {
            // ✅ REGISTRAR LOG DE ENTREGA
            registrarActividad(
                null,
                'ENTREGAR_ALBARAN', 
                `Marcó albarán ID ${albaranId} como entregado`,
                {
                    albaran_id: albaranId,
                    estado_anterior: 'enviado',
                    estado_nuevo: 'entregado',
                    receptor_confirma: receptor_confirma
                },
                req
            );
            
            res.json({ mensaje: 'Albarán marcado como entregado' });
        }
    });
});

// 🖨️ RUTA: Imprimir albarán (básico)
app.get('/albaranes/:id/imprimir', (req, res) => {
    const albaranId = req.params.id;
    
    // Obtener datos del albarán
    const queryAlbaran = 'SELECT * FROM albaranes WHERE id = ?';
    
    db.query(queryAlbaran, [albaranId], (err, albaranResults) => {
        if (err) {
            console.log('Error obteniendo albarán para imprimir:', err);
            return res.status(500).json({ error: 'Error en la base de datos' });
        }
        
        if (albaranResults.length === 0) {
            return res.status(404).json({ error: 'Albarán no encontrado' });
        }
        
        // Obtener productos del albarán
        const queryProductos = `
            SELECT 
                al.cantidad,
                al.observaciones,
                p.referencia,
                p.descripcion
            FROM albaran_lineas al
            JOIN productos p ON al.producto_id = p.id
            WHERE al.albaran_id = ?
            ORDER BY p.referencia ASC
        `;
        
        db.query(queryProductos, [albaranId], (err2, productosResults) => {
            if (err2) {
                console.log('Error obteniendo productos para imprimir:', err2);
                return res.status(500).json({ error: 'Error en la base de datos' });
            }
            
            // Calcular resumen
            const totalTipos = productosResults.length;
            const totalUnidades = productosResults.reduce((sum, p) => sum + p.cantidad, 0);
            
            // ✅ REGISTRAR LOG DE IMPRESIÓN
            registrarActividad(
                null, // Cambiar por req.usuario?.id cuando implementes autenticación completa
                'IMPRIMIR_ALBARAN', 
                `Imprimió albarán ${albaranResults[0].numero_albaran}`,
                {
                    albaran_id: albaranId,
                    numero_albaran: albaranResults[0].numero_albaran,
                    cliente: albaranResults[0].cliente,
                    total_productos: totalTipos,
                    total_unidades: totalUnidades
                },
                req
            );
            
            res.json({
                exito: true,
                albaran: albaranResults[0],
                productos: productosResults,
                resumen: { 
                    total_tipos: totalTipos, 
                    total_unidades: totalUnidades 
                },
                fecha_impresion: new Date().toISOString(),
                mensaje: 'Datos de impresión obtenidos'
            });
        });
    });
});

// =================================
// 🚀 INICIAR SERVIDOR
// =================================

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    console.log(`🌐 Red local: http://192.168.1.207:${PORT}`);
    console.log(`📋 Prueba API: http://192.168.1.207:${PORT}/albaranes`);
    console.log(`📦 Productos: http://192.168.1.207:${PORT}/productos`);
    console.log(`👥 Usuarios: http://192.168.1.207:${PORT}/usuarios`);
    console.log(`🔐 Login: http://192.168.1.207:${PORT}/usuarios/login`);
    console.log(`📝 Logs: http://192.168.1.207:${PORT}/logs/actividad`);
    console.log(`🚀 Setup: http://192.168.1.207:${PORT}/setup/primer-admin`);
    console.log(`==========================================`);
    console.log(`✅ Sistema MOLINCAR listo para funcionar`);
    
    // ✅ REGISTRAR INICIO DEL SISTEMA (después de 3 segundos)
    setTimeout(() => {
        registrarActividad(
            null, 
            'SISTEMA_INICIO', 
            `Servidor MOLINCAR iniciado en puerto ${PORT}`,
            {
                puerto: PORT,
                version: '2.0.0',
                timestamp: new Date().toISOString(),
                endpoints_disponibles: [
                    '/albaranes', '/productos', '/usuarios', '/logs/actividad'
                ]
            }
        );
        console.log('📝 Log de inicio del sistema registrado');
    }, 3000); // Esperar 3 segundos para que la DB esté lista
    
    // 🧪 LOGS DE PRUEBA (TEMPORAL - puedes quitar esto después)
    setTimeout(() => {
        console.log('🧪 Creando logs de prueba...');
        
        registrarActividad(null, 'TEST', 'Probando el sistema de logs', {test: true});
        registrarActividad(null, 'CREAR_PRODUCTO', 'Creó producto de prueba: TEST001 - Producto de prueba', {referencia: 'TEST001', test: true});
        registrarActividad(null, 'CREAR_ALBARAN', 'Creó albarán de prueba: 2025-TEST para cliente: Cliente de Prueba', {numero: '2025-TEST', test: true});
        
        console.log('✅ Logs de prueba creados. Verifica en la app o en MySQL:');
        console.log('   SELECT * FROM logs_actividad ORDER BY created_at DESC LIMIT 5;');
    }, 5000); // Esperar 5 segundos
});