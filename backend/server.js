const express = require('express');
// 📦 Importamos la librería Express que instalamos con npm
// Es como decir: "Voy a usar las herramientas de Express"

const app = express();
// 🏗️ Creamos nuestra aplicación web
// 'app' es nuestro servidor, donde vamos a definir todas las rutas

const PORT = 3000;
// 🚪 Definimos el "puerto" donde va a escuchar nuestro servidor
// Es como la "dirección" donde Flutter va a conectarse
// Podría ser 3000, 8080, 5000... el que tú quieras

// Importar la conexión a la base de datos
const db = require('./database');
// Middleware para parsear JSON


app.use(express.json());
// 🔧 Le decimos a Express: "cuando recibas datos, conviértelos a JSON"
// Flutter va a enviar datos en formato JSON, esto los convierte automáticamente

// Ruta de prueba
app.get('/', (req, res) => {
    res.json({ mensaje: 'API del almacén funcionando!' });
});
// 🛣️ Definimos una "ruta" (endpoint)
// app.get = cuando alguien haga una petición GET a "/"
// (req, res) = req=petición que llega, res=respuesta que enviamos
// res.json() = enviamos una respuesta en formato JSON
// Ruta para obtener todos los productos
app.get('/productos', (req, res) => {
    db.query('SELECT * FROM productos', (err, results) => {
        if (err) {
            console.log('Error en consulta:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});

// Ruta para obtener todos los albaranes
app.get('/albaranes', (req, res) => {
    db.query('SELECT * FROM albaranes ORDER BY fecha_creacion DESC', (err, results) => {
        if (err) {
            console.log('Error en consulta albaranes:', err);
            res.status(500).json({ error: 'Error en la base de datos' });
        } else {
            res.json(results);
        }
    });
});


// Ruta para crear un nuevo albarán
app.post('/albaranes', (req, res) => {
    const { numero_albaran, cliente, direccion_entrega, observaciones } = req.body;
    
    const query = 'INSERT INTO albaranes (numero_albaran, cliente, direccion_entrega, observaciones) VALUES (?, ?, ?, ?)';
    
    db.query(query, [numero_albaran, cliente, direccion_entrega, observaciones], (err, results) => {
        if (err) {
            console.log('Error creando albarán:', err);
            res.status(500).json({ error: 'Error creando albarán' });
        } else {
            res.json({ 
                id: results.insertId, 
                mensaje: 'Albarán creado correctamente' 
            });
        }
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
// 🚀 Ponemos el servidor "a escuchar" en el puerto 3000
// La función () => {} se ejecuta cuando el servidor arranca
// console.log() imprime un mensaje en la terminal