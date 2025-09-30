# KipuBank

## Descripción

**KipuBank** es un contrato inteligente en Solidity que permite a los usuarios depositar y retirar tokens nativos de Ethereum (ETH) en una bóveda personal. El sistema implementa medidas de seguridad y límites para ofrecer una experiencia bancaria simple y segura en la blockchain.

**Características principales**:
- **Depósitos**: Cualquier usuario puede depositar ETH en su propia bóveda.
- **Retiros**: Cada usuario puede retirar fondos de su bóveda, pero solo hasta un máximo fijo por transacción.
- **Límite global**: Hay un tope total (cap) de ETH que puede contener el contrato, definido al desplegarlo.
- **Seguridad**: Uso de errores personalizados, patrón checks-effects-interactions y manejo seguro de transferencias.
- **Eventos**: Se emiten eventos en cada depósito y retiro exitoso.
- **Contadores**: Se lleva registro del número de depósitos y retiros tanto globalmente como por usuario.

---

## Instrucciones de Despliegue

### Requisitos previos

- Node.js y npm instalados
- [Remix](https://remix.ethereum.org/) para desarrollo y pruebas
- Una wallet compatible con Ethereum, tipo MetaMask
- ETH de prueba para la red seleccionada.

### Pasos para el despliegue

1. **Cloná el repositorio o copiá el contrato `KipuBank.sol` a tu proyecto.**

2. **Configura tu entorno de desarrollo.**
   - En Remix: Abrí Remix y creá un nuevo archivo `KipuBank.sol`.

3. **Compila el contrato.**
   - En Remix: Hacé clic en el botón de "Compile".

4. **Despliega el contrato.**
   - Debés especificar los tres parámetros del constructor:
     - `bankCap`: Límite global de ETH en wei
     - `perTxWithdrawLimit`: Límite de retiro por transacción en wei
   - Ejemplo de despliegue en Remix:
     ```
     bankCap = 10 ether
     perTxWithdrawLimit = 1 ether
     ```
     Asegurate de ingresar los valores en wei o usando el helper de Remix.

5. **Confirmá el despliegue y guardá la dirección del contrato.**

---

## Cómo interactuar con el contrato

Podés interactuar con KipuBank desde Remix, scripts personalizados o una dApp. Acá te mostramos los métodos principales:

### 1. Depositar ETH

- Llamá a la función `deposit()` enviando ETH junto a la transacción.
- Ejemplo en Remix:
  - Ingresá la cantidad de ETH en el campo "Value" (en wei).
  - Hacé clic en `deposit`.

### 2. Retirar ETH

- Llamá a la función `withdraw(uint256 amount)` especificando el monto a retirar (en wei).
- Sólo podés retirar hasta el límite por transacción y hasta el monto de tu saldo.

### 3. Consultar tu saldo

- Llamá a `getVaultBalance(address user)` pasando tu dirección para obtener tu saldo en la bóveda.

### 4. Consultar otros datos

- Podés consultar:
  - `depositCount(address)`: Número de depósitos realizados por un usuario.
  - `withdrawalCount(address)`: Número de retiros realizados por un usuario.
  - `totalDeposited()`: Suma global de ETH depositado.

### 5. Eventos

- Observá los eventos `Deposit` y `Withdraw` en los logs de transacciones para monitorear depósitos y retiros.

---

## Notas y recomendaciones

- Asegurate de no exceder los límites establecidos para depósitos y retiros, o la transacción revertirá con un error personalizado.
- Todas las transferencias de ETH son manejadas de forma segura siguiendo las mejores prácticas de Solidity.
- Si el contrato recibe ETH directamente (sin usar la función `deposit`), la transacción será revertida.

---

## Licencia

MIT

---
