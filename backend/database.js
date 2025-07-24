const { Pool } = require('pg');

// 🔧 CONFIGURACIÓN DE CONEXIÓN POSTGRESQL SUPABASE
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false
    }
});

// 🔍 PROBAR LA CONEXIÓN AL INICIALIZAR
pool.connect((err, client, release) => {
    if (err) {
        console.log('❌ Error conectando a PostgreSQL Supabase:', err.message);
        console.log('🔧 Verifica la variable DATABASE_URL');
    } else {
        console.log('✅ Conectado a PostgreSQL Supabase correctamente');
        console.log(`📊 Database: ${client.database}`);
        console.log(`🏠 Host: ${client.host}`);
        release();
    }
});

// 🔄 MANEJAR ERRORES DE CONEXIÓN
pool.on('error', (err) => {
    console.log('❌ Error inesperado en PostgreSQL:', err);
});

// 📤 EXPORTAR EL POOL PARA USAR EN QUERIES
module.exports = pool;