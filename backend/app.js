// 🚀 PUNTO DE ENTRADA PARA PASSENGER (SERED HOSTING)
// Sistema MOLINCAR - molincar.guitarradeluena.site

console.log('🚀 Iniciando Sistema MOLINCAR...');
console.log(`📅 Fecha: ${new Date().toISOString()}`);
console.log(`🌐 Entorno: ${process.env.NODE_ENV || 'development'}`);
console.log(`📂 Directorio: ${__dirname}`);
console.log(`🌍 Dominio: https://molincar.guitarradeluena.site`);

// 📦 IMPORTAR Y INICIAR LA APLICACIÓN PRINCIPAL
const app = require('./server');

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

// 📤 EXPORTAR LA APLICACIÓN PARA PASSENGER
module.exports = app;

console.log('✅ Sistema MOLINCAR inicializado correctamente');
console.log('🌐 Acceso: https://molincar.guitarradeluena.site');