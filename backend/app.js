// 🚀 PUNTO DE ENTRADA PARA PASSENGER (SERED HOSTING)
// Sistema MOLINCAR - molincar.guitarradeluena.site
// ✅ VERSIÓN SEGURA: Solo añade keep-alive sin romper el código existente

console.log('🚀 Iniciando Sistema MOLINCAR...');
console.log(`📅 Fecha: ${new Date().toISOString()}`);
console.log(`🌐 Entorno: ${process.env.NODE_ENV || 'development'}`);
console.log(`📂 Directorio: ${__dirname}`);
console.log(`🌍 Dominio: https://molincar.guitarradeluena.site`);

// 📦 IMPORTAR Y INICIAR LA APLICACIÓN PRINCIPAL
const app = require('./server');

// 🔄 SISTEMA KEEP-ALIVE SIMPLE (NO ROMPE NADA)
let keepAliveInterval;

// 📊 FUNCIÓN: Ping simple a la base de datos
function keepDatabaseAlive() {
    try {
        const db = require('./database');
        
        // Usar la función query existente
        db.query('SELECT 1 as ping', (err, results) => {
            if (err) {
                console.log('❌ Error en ping BD:', err.message);
            } else {
                console.log(`💚 BD mantiene vida: ${new Date().toLocaleTimeString()}`);
            }
        });
    } catch (error) {
        console.log('❌ Error en keepDatabaseAlive:', error.message);
    }
}

// 🔄 FUNCIÓN: Auto-ping HTTP para mantener Node.js activo
function keepNodeAlive() {
    try {
        const https = require('https');
        
        const options = {
            hostname: 'molincar.guitarradeluena.site',
            port: 443,
            path: '/',
            method: 'GET',
            timeout: 8000,
            headers: {
                'User-Agent': 'MOLINCAR-KeepAlive/1.0'
            }
        };
        
        const req = https.request(options, (res) => {
            console.log(`💚 Node.js mantiene vida: ${res.statusCode} - ${new Date().toLocaleTimeString()}`);
        });
        
        req.on('error', (err) => {
            console.log('❌ Error en ping Node.js:', err.message);
        });
        
        req.on('timeout', () => {
            console.log('⏰ Timeout en ping Node.js');
            req.destroy();
        });
        
        req.end();
    } catch (error) {
        console.log('❌ Error en keepNodeAlive:', error.message);
    }
}

// 📊 ENDPOINT ADICIONAL: Health check simple
app.get('/health', (req, res) => {
    try {
        const db = require('./database');
        
        // Test simple de conexión
        db.query('SELECT NOW() as tiempo', (err, results) => {
            if (err) {
                res.status(500).json({
                    estado: 'ERROR',
                    mensaje: 'Base de datos no disponible',
                    error: err.message,
                    timestamp: new Date().toISOString()
                });
            } else {
                res.json({
                    estado: 'OK',
                    mensaje: 'Sistema MOLINCAR funcionando',
                    base_datos: 'Conectada',
                    servidor_tiempo: results[0] ? results[0].tiempo : new Date(),
                    uptime: Math.floor(process.uptime()),
                    version: '2.0-SERED-SAFE',
                    keepalive: keepAliveInterval ? 'ACTIVO' : 'INACTIVO',
                    timestamp: new Date().toISOString()
                });
            }
        });
    } catch (error) {
        res.status(500).json({
            estado: 'ERROR',
            mensaje: 'Error interno',
            error: error.message,
            timestamp: new Date().toISOString()
        });
    }
});

// 🎯 ENDPOINT: Wake-up manual
app.post('/wake-up', (req, res) => {
    console.log('🔥 Wake-up manual solicitado');
    
    try {
        keepDatabaseAlive();
        setTimeout(() => keepNodeAlive(), 1000);
        
        res.json({
            mensaje: 'Sistema reactivado manualmente',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({
            error: 'Error en wake-up',
            mensaje: error.message,
            timestamp: new Date().toISOString()
        });
    }
});

// 📊 MOSTRAR INFORMACIÓN DE CONFIGURACIÓN
console.log('⚙️  CONFIGURACIÓN MOLINCAR:');
console.log(`   Puerto: ${process.env.PORT || '3000'}`);
console.log(`   Base de datos: ${process.env.DB_NAME || 'ite2guita_logistica_almacen_app'}`);
console.log(`   Host DB: ${process.env.DB_HOST || 'localhost'}`);
console.log(`   Usuario DB: ${process.env.DB_USER || 'ite2guita_logistica_almacen'}`);
console.log(`   JWT Secret: ${process.env.JWT_SECRET ? 'CONFIGURADO' : 'USANDO DEFAULT'}`);

// 🎯 MANEJAR ERRORES NO CAPTURADOS
process.on('uncaughtException', (error) => {
    console.error('❌ Error no capturado MOLINCAR:', error);
    // No cerrar el proceso en producción para evitar caídas del servidor
    if (process.env.NODE_ENV !== 'production') {
        process.exit(1);
    }
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Promesa rechazada no manejada en MOLINCAR:', promise, 'razón:', reason);
});

// 🔄 INICIALIZAR KEEP-ALIVE DESPUÉS DE 5 SEGUNDOS (para asegurar que todo esté listo)
setTimeout(() => {
    try {
        console.log('🔄 Iniciando sistema Keep-Alive SEGURO...');
        
        // Ping cada 4 minutos (más conservador)
        keepAliveInterval = setInterval(() => {
            keepDatabaseAlive();
        }, 4 * 60 * 1000); // 4 minutos
        
        // Ping Node.js cada 4.5 minutos
        setInterval(() => {
            keepNodeAlive();
        }, 4.5 * 60 * 1000); // 4.5 minutos
        
        console.log('✅ Keep-Alive SEGURO configurado: BD cada 4min, Node.js cada 4.5min');
        
        // Test inicial
        keepDatabaseAlive();
        
    } catch (error) {
        console.error('❌ Error configurando keep-alive:', error);
    }
}, 5000);

// 📤 EXPORTAR LA APLICACIÓN PARA PASSENGER
module.exports = app;

console.log('✅ Sistema MOLINCAR inicializado correctamente');
console.log('🌐 Acceso: https://molincar.guitarradeluena.site');
console.log('🔗 Health check: /health');
console.log('🔄 Wake-up: POST /wake-up');