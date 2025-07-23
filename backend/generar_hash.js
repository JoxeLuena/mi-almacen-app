const bcrypt = require('bcrypt');

async function generarHashes() {
    try {
        // Generar hash para contraseña "Inpre2015"
        const password1 = 'Inpre2015';
        const hash1 = await bcrypt.hash(password1, 10);
        console.log(`Contraseña: ${password1}`);
        console.log(`Hash: ${hash1}`);
        console.log('---');
        
        // Generar hash para contraseña "123456" (más simple para pruebas)
        const password2 = '123456';
        const hash2 = await bcrypt.hash(password2, 10);
        console.log(`Contraseña: ${password2}`);
        console.log(`Hash: ${hash2}`);
        console.log('---');
        
        // Verificar que el hash funciona
        const esValido = await bcrypt.compare(password1, hash1);
        console.log(`Verificación hash: ${esValido}`);
        
    } catch (error) {
        console.error('Error:', error);
    }
}

// Ejecutar la función
generarHashes();