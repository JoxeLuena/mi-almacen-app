const express = require('express');        // 📦 Importar Express
const cors = require('cors');              // 🌐 Importar CORS
const app = express();                     // 🏗️ Crear nuestra aplicación web
const PORT = 3000;                         // 🚪 Puerto donde escucha el servidor

// Importar la conexión a la base de datos
const db = require('./database');          // 🗄️ Conexión a MySQL

// 🔧 CONFIGURAR CORS: Permitir peticiones desde el navegador
app.use(cors({
    origin: '*',                           // 🌍 Permitir peticiones desde cualquier origen (desarrollo)
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // 📋 Métodos HTTP permitidos
    allowedHeaders: ['Content-Type', 'Authorization'] // 📨 Headers permitidos
}));

// Middleware para parsear JSON
app.use(express.json());                   // 🔧 Convertir datos recibidos a JSON automáticamente

// 🛣️ RUTA DE PRUEBA: Verificar que la API funciona
app.get('/', (req, res) => {
    res.json({ mensaje: 'API del almacén funcionando!' }); // 📨 Respuesta de prueba
});

// 🛣️ RUTA: Obtener todos los productos
app.get('/productos', (req, res) => {
    db.query('SELECT * FROM productos', (err, results) => { // 🗄️ Consulta SQL
        if (err) {                         // ❌ Si hay error en la base de datos
            console.log('Error en consulta:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {                           // ✅ Si todo va bien
            res.json(results);             // 📨 Enviar productos en formato JSON
        }
    });
});

// 🛣️ RUTA: Obtener todos los albaranes (ordenados por fecha, más reciente primero)
app.get('/albaranes', (req, res) => {
    db.query('SELECT * FROM albaranes ORDER BY fecha_creacion DESC', (err, results) => { // 🗄️ Consulta SQL con orden
        if (err) {                         // ❌ Si hay error en la base de datos
            console.log('Error en consulta albaranes:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {                           // ✅ Si todo va bien
            res.json(results);             // 📨 Enviar albaranes en formato JSON
        }
    });
});

// 🛣️ RUTA: Crear un nuevo albarán
app.post('/albaranes', (req, res) => {
    // 📥 Extraer datos del cuerpo de la petición (lo que envía Flutter)
    const { numero_albaran, cliente, direccion_entrega, observaciones } = req.body;
    
    // 📝 Consulta SQL para insertar nuevo albarán
    const query = 'INSERT INTO albaranes (numero_albaran, cliente, direccion_entrega, observaciones) VALUES (?, ?, ?, ?)';
    
    // 🗄️ Ejecutar la consulta con los datos
    db.query(query, [numero_albaran, cliente, direccion_entrega, observaciones], (err, results) => {
        if (err) {                         // ❌ Si hay error al crear
            console.log('Error creando albarán:', err);
            res.status(500).json({ error: 'Error creando albarán' });
        } else {                           // ✅ Si se creó correctamente
            res.json({ 
                id: results.insertId,      // 🆔 ID del nuevo albarán creado
                mensaje: 'Albarán creado correctamente' 
            });
        }
    });
});

// 🚀 INICIAR SERVIDOR: Poner a escuchar en el puerto especificado
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`); // 📢 Mensaje de confirmación
});