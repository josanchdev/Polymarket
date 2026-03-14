# Proyecto: Casa de Apuestas Descentralizada 🎲

Este proyecto consiste en el desarrollo de un conjunto de Smart Contracts en Solidity para simular el funcionamiento de una Casa de Apuestas utilizando un Token ERC-20 personalizado. 

El proyecto cumple con los requisitos de diseño donde un "Caso de Estudio" (La Casa de Apuestas) tiene control total sobre la inicialización y el suministro de un Token, justificando técnicamente el uso de operaciones de creación (`mint`) y destrucción (`burn`) de activos.

## 🏗️ Arquitectura de los Smart Contracts

El sistema está compuesto por tres contratos principales, diseñados siguiendo los estándares de la industria y utilizando herencia para mantener un código modular y seguro:

1.  **`ERC20Padre.sol`**: 
    Contiene la lógica estándar del protocolo ERC-20. Gestiona los balances, los permisos (`allowances`) y las funciones de transferencia básicas. Sus variables de estado están encapsuladas (`private`) y expone funciones internas (`_mint`, `_burn`) para que los contratos hijos puedan utilizarlas de forma segura.

2.  **`ApuestasToken.sol`**: 
    Contrato hijo que hereda de `ERC20Padre`. Implementa modificadores de acceso (`onlyOwner`) y expone funciones externas controladas (`ownerMint`, `ownerBurn`, `burn`) para alterar el suministro de tokens. Su inicialización se realiza delegando parámetros al constructor padre.

3.  **`CasaApuestas.sol`**: 
    Es el contrato principal ("Caso de Estudio"). Actúa como el motor del sistema. 
    * **Inicialización:** Despliega el contrato `ApuestasToken` desde su propio constructor, convirtiéndose así en el `owner` absoluto del token.
    * **Lógica de Negocio:** Permite comprar fichas pagando ETH, crear eventos deportivos, apostar y resolver los resultados repartiendo premios de forma proporcional entre los ganadores.

## ⚙️ Justificación Técnica de Mint y Burn

El uso del token en esta Casa de Apuestas justifica la necesidad de crear y destruir tokens dinámicamente:
* **Mint (Creación):** Se utiliza cuando un usuario deposita Ethers a cambio de fichas (`comprarFichas`) y cuando un usuario gana una apuesta, generándose nuevos tokens para pagarle su premio (`resolverEvento`).
* **Burn (Destrucción):** Se utiliza en el momento en el que el jugador confirma una apuesta (`apostar`). En lugar de transferir el token a la casa, el token se "quema" o arriesga. Si el jugador pierde, el token permanece destruido; si gana, se le restituye mediante un nuevo mint.

## 🚀 Cómo desplegar en Remix IDE

1.  Abre [Remix IDE](https://remix.ethereum.org/) y sube los tres archivos `.sol` en la carpeta `contracts`.
2.  Compila el archivo `CasaApuestas.sol` (las dependencias se compilarán automáticamente).
3.  Ve a la pestaña de "Deploy & Run Transactions".
4.  Selecciona el contrato `CasaApuestas` en el desplegable.
5.  Despliega la pestaña del botón naranja "Deploy" y rellena los 3 parámetros de inicialización del token:
    * `tokenName`: Ej. "FichasCasino"
    * `tokenSymbol`: Ej. "FCH"
    * `tokenDecimals`: Ej. 0 (Recomendado para pruebas sin decimales).
6.  Pulsa "Transact". El sistema estará listo para ser utilizado.