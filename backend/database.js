const mysql = require('mysql2');

// Configuración de la conexión
const connection = mysql.createConnection({
    host: '127.0.0.1',
    port: 3306,
    user: 'root',           // 👈 CAMBIO AQUÍ
    password: 'Inpre2015',
    database: 'almacen_app'
});

// Probar la conexión
connection.connect((err) => {
    if (err) {
        console.log('❌ Error conectando a MySQL:', err);
    } else {
        console.log('✅ Conectado a MySQL correctamente');
    }
});

// Exportar la conexión para usarla en otros archivos
module.exports = connection;