# Zonix Eats Echo Server - WebSocket Server

## 📋 Descripción

Servidor WebSocket para Zonix Eats basado en Laravel Echo Server. Maneja la comunicación en tiempo real para notificaciones, chat y tracking de pedidos.

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │  Echo Server    │    │    Backend      │
│   (Flutter)     │◄──►│  (WebSocket)    │◄──►│   (Laravel)     │
│                 │    │                 │    │                 │
│ - Socket.io     │    │ - Socket.io     │    │ - Broadcasting  │
│ - Event Listeners│   │ - Redis         │    │ - Events        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Instalación

### Prerrequisitos
- Node.js 16+
- npm/npx
- Redis (opcional, para clustering)

### Configuración

1. **Instalar dependencias**
```bash
npm install
```

2. **Configurar servidor**
```bash
npx laravel-echo-server init
```

3. **Configuración recomendada**
```json
{
  "authHost": "http://192.168.0.101:8000",
  "authEndpoint": "/broadcasting/auth",
  "clients": [
    {
      "appId": "zonix-eats",
      "key": "your-app-key"
    }
  ],
  "database": "redis",
  "databaseConfig": {
    "redis": {
      "host": "127.0.0.1",
      "port": 6379
    }
  },
  "devMode": true,
  "host": "0.0.0.0",
  "port": 6001,
  "protocol": "http",
  "socketio": {},
  "sslCertPath": "",
  "sslKeyPath": "",
  "sslCertChainPath": "",
  "sslPassphrase": "",
  "subscribers": {
    "http": true,
    "redis": true
  },
  "apiOriginAllow": {
    "allowCors": true,
    "allowOrigin": "*",
    "allowMethods": "GET, POST",
    "allowHeaders": "Origin, Content-Type, X-Auth-Token, X-Requested-With, Accept, Authorization, X-CSRF-TOKEN, X-Socket-Id"
  }
}
```

4. **Iniciar servidor**
```bash
npx laravel-echo-server start
```

## 🔧 Configuración Detallada

### Variables de Entorno
```bash
# Configuración del servidor
ECHO_SERVER_HOST=0.0.0.0
ECHO_SERVER_PORT=6001
ECHO_SERVER_PROTOCOL=http

# Configuración de autenticación
ECHO_SERVER_AUTH_HOST=http://192.168.0.101:8000
ECHO_SERVER_AUTH_ENDPOINT=/broadcasting/auth

# Configuración de base de datos
ECHO_SERVER_DB=redis
ECHO_SERVER_REDIS_HOST=127.0.0.1
ECHO_SERVER_REDIS_PORT=6379

# Configuración de SSL (producción)
ECHO_SERVER_SSL_CERT_PATH=
ECHO_SERVER_SSL_KEY_PATH=
```

### Configuración de CORS
```json
{
  "apiOriginAllow": {
    "allowCors": true,
    "allowOrigin": "*",
    "allowMethods": "GET, POST",
    "allowHeaders": "Origin, Content-Type, X-Auth-Token, X-Requested-With, Accept, Authorization, X-CSRF-TOKEN, X-Socket-Id"
  }
}
```

## 📡 Eventos WebSocket

### Eventos de Notificación

#### OrderStatusChanged
```javascript
// Frontend (Flutter)
Echo.private(`user.${userId}`)
    .listen('OrderStatusChanged', (e) => {
        print('Orden actualizada: ${e.order}');
    });

// Backend (Laravel)
event(new OrderStatusChanged($order));
```

#### NewNotification
```javascript
// Frontend
Echo.private(`user.${userId}`)
    .listen('NewNotification', (e) => {
        print('Nueva notificación: ${e.notification}');
    });

// Backend
event(new NewNotification($notification));
```

### Eventos de Chat

#### ChatMessageSent
```javascript
// Frontend
Echo.private(`chat.${orderId}`)
    .listen('ChatMessageSent', (e) => {
        print('Nuevo mensaje: ${e.message}');
    });

// Backend
event(new ChatMessageSent($message));
```

#### UserTyping
```javascript
// Frontend
Echo.private(`chat.${orderId}`)
    .listen('UserTyping', (e) => {
        print('Usuario escribiendo: ${e.userId}');
    });

// Backend
event(new UserTyping($userId, $orderId));
```

### Eventos de Tracking

#### LocationUpdated
```javascript
// Frontend
Echo.private(`delivery.${orderId}`)
    .listen('LocationUpdated', (e) => {
        print('Ubicación actualizada: ${e.location}');
    });

// Backend
event(new LocationUpdated($location, $orderId));
```

#### OrderAssigned
```javascript
// Frontend
Echo.private(`delivery.${deliveryId}`)
    .listen('OrderAssigned', (e) => {
        print('Orden asignada: ${e.order}');
    });

// Backend
event(new OrderAssigned($order, $deliveryId));
```

## 🔐 Autenticación

### Configuración en Laravel
```php
// config/broadcasting.php
'defaults' => [
    'guard' => 'web',
    'middleware' => [
        'auth:sanctum',
    ],
],

'connections' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'default',
    ],
],
```

### Middleware de Autenticación
```php
// app/Http/Middleware/Authenticate.php
protected function authenticate($request, array $guards)
{
    if (empty($guards)) {
        $guards = [null];
    }

    foreach ($guards as $guard) {
        if ($this->auth->guard($guard)->check()) {
            return $this->auth->shouldUse($guard);
        }
    }

    throw new AuthenticationException(
        'Unauthenticated.', $guards, $this->redirectTo($request)
    );
}
```

## 📊 Canales de Broadcasting

### Canales Públicos
```javascript
// Cualquier usuario puede suscribirse
Echo.channel('public-orders')
    .listen('OrderCreated', (e) => {
        print('Nueva orden pública: ${e.order}');
    });
```

### Canales Privados
```javascript
// Solo usuarios autenticados
Echo.private(`user.${userId}`)
    .listen('OrderStatusChanged', (e) => {
        print('Mi orden actualizada: ${e.order}');
    });
```

### Canales de Presencia
```javascript
// Usuarios en línea
Echo.join(`chat.${orderId}`)
    .here((users) => {
        print('Usuarios en línea: ${users.length}');
    })
    .joining((user) => {
        print('Usuario se unió: ${user.name}');
    })
    .leaving((user) => {
        print('Usuario se fue: ${user.name}');
    });
```

## 🧪 Testing

### Tests de Conexión
```javascript
// Test básico de conexión
const io = require('socket.io-client');
const socket = io('http://192.168.0.101:6001');

socket.on('connect', () => {
    console.log('Conectado al Echo Server');
});

socket.on('disconnect', () => {
    console.log('Desconectado del Echo Server');
});
```

### Tests de Eventos
```javascript
// Test de eventos
socket.emit('join', { channel: 'test-channel' });

socket.on('test-event', (data) => {
    console.log('Evento recibido:', data);
});
```

## 📈 Monitoreo

### Logs del Servidor
```bash
# Ver logs en tiempo real
tail -f laravel-echo-server.log

# Logs de errores
grep "ERROR" laravel-echo-server.log

# Logs de conexiones
grep "CONNECT" laravel-echo-server.log
```

### Métricas
- Conexiones activas
- Eventos por segundo
- Latencia promedio
- Errores de conexión

### Health Check
```bash
# Verificar estado del servidor
curl http://192.168.0.101:6001/health

# Verificar conectividad WebSocket
wscat -c ws://192.168.0.101:6001
```

## 🔧 Configuración de Producción

### SSL/TLS
```json
{
  "protocol": "https",
  "sslCertPath": "/path/to/cert.pem",
  "sslKeyPath": "/path/to/key.pem",
  "sslCertChainPath": "/path/to/chain.pem",
  "sslPassphrase": "your-passphrase"
}
```

### Clustering con Redis
```json
{
  "database": "redis",
  "databaseConfig": {
    "redis": {
      "host": "127.0.0.1",
      "port": 6379,
      "password": "your-redis-password"
    }
  }
}
```

### Load Balancer
```nginx
# Nginx configuration
upstream echo_server {
    server 127.0.0.1:6001;
    server 127.0.0.1:6002;
    server 127.0.0.1:6003;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://echo_server;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🐛 Troubleshooting

### Problemas Comunes

1. **Error de conexión**
   ```bash
   # Verificar puerto
   netstat -tulpn | grep 6001
   
   # Verificar firewall
   sudo ufw status
   ```

2. **Error de autenticación**
   ```bash
   # Verificar configuración de Laravel
   php artisan config:clear
   php artisan route:clear
   ```

3. **Error de CORS**
   ```json
   {
     "apiOriginAllow": {
       "allowCors": true,
       "allowOrigin": "*"
     }
   }
   ```

### Debug Mode
```bash
# Iniciar en modo debug
DEBUG=* npx laravel-echo-server start
```

## 📊 Performance

### Optimizaciones
- Usar Redis para clustering
- Configurar SSL en producción
- Implementar rate limiting
- Monitorear uso de memoria

### Métricas de Rendimiento
- Latencia < 100ms
- Throughput > 1000 eventos/seg
- Uso de memoria < 512MB
- CPU < 50%

---

**Versión**: 1.6.3  
**Node.js**: 16+  
**Protocolo**: Socket.io  
**Última actualización**: Julio 2024 