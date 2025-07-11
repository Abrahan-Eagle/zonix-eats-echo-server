# Zonix Echo Server

Servidor de WebSockets para Zonix Eats, basado en [Laravel Echo Server](https://github.com/tlaverdure/laravel-echo-server). Permite notificaciones en tiempo real entre backend y frontend (por ejemplo, actualizaciones de pedidos, mensajes de chat, etc).

---

## 📦 Estructura del proyecto

```
zonix-echo-server/
├── laravel-echo-server.json   # Configuración principal
├── package.json              # Dependencias Node.js
├── start.sh                  # Script de inicio (opcional)
├── README.md                 # Este archivo
└── ...
```

---

## ⚙️ Configuración

1. Instala dependencias:
   ```bash
   npm install
   ```
2. Configura `laravel-echo-server.json` según tus necesidades (puerto, drivers, claves, etc).
   - Por defecto, escucha en el puerto 6001.
   - Puedes usar SQLite, Redis u otro driver para broadcasting.

---

## 🚀 Cómo ejecutar el servidor

```bash
npx laravel-echo-server start
```
O si tienes un script:
```bash
npm start
```

El servidor quedará escuchando en el puerto configurado (por defecto, 6001).

---

## 📡 Canales y eventos de WebSockets

### ¿Qué es un canal?
Un canal es una “sala” de comunicación donde los clientes (apps) y el backend pueden enviar y recibir mensajes en tiempo real. Los canales pueden ser públicos, privados o de presencia.

### Ejemplo de estructura de canales y eventos

#### 1. Canales públicos
- `orders`  
  Notificaciones generales sobre pedidos (por ejemplo, nuevos pedidos para comercios).

#### 2. Canales privados
- `private-orders.{orderId}`  
  Notificaciones específicas de un pedido (actualización de estado, mensajes de chat, etc).
- `private-user.{userId}`  
  Notificaciones personales para un usuario (por ejemplo, confirmación de pago, mensajes directos).

#### 3. Canales de presencia
- `presence-chat.{orderId}`  
  Para chats en tiempo real entre cliente, comercio y repartidor en un pedido.

### Ejemplo de eventos

| Evento               | Canal                    | Descripción                                      |
|----------------------|--------------------------|--------------------------------------------------|
| OrderStatusChanged   | private-orders.{orderId} | Se emite cuando cambia el estado de un pedido.   |
| NewMessage           | presence-chat.{orderId}  | Se emite cuando hay un nuevo mensaje en el chat. |
| OrderCreated         | orders                   | Se emite cuando se crea un nuevo pedido.         |

### Ejemplo de emisión de evento en Laravel

```php
// app/Events/OrderStatusChanged.php
class OrderStatusChanged implements ShouldBroadcast
{
    public $order;
    public function __construct($order) { $this->order = $order; }
    public function broadcastOn() {
        return new PrivateChannel('orders.' . $this->order->id);
    }
    public function broadcastWith() {
        return ['order' => $this->order];
    }
}
```

### Ejemplo de escucha en el frontend (Flutter, JS, etc.)

```js
Echo.private('orders.123')
    .listen('OrderStatusChanged', (e) => {
        console.log('Estado actualizado:', e.order);
    });

Echo.join('presence-chat.123')
    .listen('NewMessage', (e) => {
        console.log('Nuevo mensaje:', e);
    });
```

### Convenciones
- Usa `private-` para canales privados y `presence-` para canales de presencia.
- El nombre del evento debe coincidir entre backend y frontend.
- Documenta los datos enviados en cada evento (`broadcastWith`).

---

## 📝 Buenas prácticas
- Mantén la configuración segura (no subas claves privadas a git).
- Usa HTTPS en producción si es posible.
- Documenta los canales y eventos que usas en tu app.

---

## 📄 Contacto y soporte
Para dudas o soporte, contacta a tu equipo de desarrollo o abre un issue en el repositorio. 