# Guía de Pruebas y Despliegue en Remix

Este documento detalla los pasos seguidos para probar el funcionamiento integral del sistema de la Casa de Apuestas, demostrando la correcta implementación de los estándares ERC-20 y los requisitos de "mint" y "burn" del caso de estudio.

## 1. Despliegue del Sistema (Setup Inicial)
Para cumplir con el requisito de que el caso de estudio controle el token, el despliegue se realiza desde la Casa de Apuestas.

* **Cuenta utilizada:** Cuenta A (Owner)
* **Acción:** Despliegue del contrato `CasaApuestas.sol`.
* **Parámetros del Token:** * `tokenName`: "FichasCasino"
    * `tokenSymbol`: "FCH"
    * `tokenDecimals`: 0 (Para facilitar la legibilidad en las pruebas).
* **Resultado:** El contrato `CasaApuestas` se despliega correctamente y, en su constructor, despliega automáticamente el `ApuestasToken`, convirtiéndose en su Owner.

![Captura: Contrato desplegado en Remix y dirección del Owner](Ruta/A/Tu/Captura_Despliegue.png)

## 2. Comprar Fichas (Demostración de MINT)
Simulamos a un jugador que ingresa dinero (ETH) para obtener fichas del casino.

* **Cuenta utilizada:** Cuenta B (Ej. Carlos)
* **Acción:** Llamada a la función `comprarFichas(1)`.
* **Valor (Value):** 10000000000000000 Wei (0.01 ETH).
* **Resultado:** La transacción es exitosa. La Casa de Apuestas recibe el ETH e invoca la función `ownerMint` del token, creando 1 ficha nueva para la Cuenta B.
* **Logs:** Se emite el evento `FichasCompradas`.

![Captura: Transacción de comprarFichas exitosa y evento emitido](Ruta/A/Tu/Captura_ComprarFichas.png)

## 3. Creación de un Evento
El dueño de la casa crea un evento deportivo para que los usuarios apuesten.

* **Cuenta utilizada:** Cuenta A (Owner)
* **Acción:** Llamada a `crearEvento("Real Madrid vs FC Barcelona")`.
* **Resultado:** Se crea el evento con el ID 1.

![Captura: Creación del evento y comprobación del ID](Ruta/A/Tu/Captura_CrearEvento.png)

## 4. Apostar en el Evento (Demostración de BURN)
El jugador utiliza sus fichas para apostar por uno de los equipos.

* **Cuenta utilizada:** Cuenta B (Carlos)
* **Acción:** Llamada a `apostar(1, 1, true)` -> Apuesta 1 ficha al evento 1 a favor del equipo A.
* **Resultado:** La Casa de Apuestas invoca `ownerBurn` sobre el saldo del jugador, destruyendo (quemando) su ficha mientras el evento está activo.
* **Logs:** Se emite el evento `ApuestaRealizada`.

![Captura: Función apostar y evento ApuestaRealizada donde se queman los tokens](Ruta/A/Tu/Captura_Apostar.png)

## 5. Pruebas de Seguridad (Forzado de Errores)
Comprobamos que el contrato es robusto frente a comportamientos no deseados.

* **Error 1: Falta de Saldo (Require de ERC20Padre)**
    * **Cuenta:** Cuenta C (Ivan - Sin fichas).
    * **Acción:** Intenta llamar a `apostar(1, 1, true)`.
    * **Resultado:** La transacción revierte por saldo insuficiente (el "burn" interno falla).
    ![Captura: Error por saldo insuficiente en la consola de Remix](Ruta/A/Tu/Captura_ErrorSaldo.png)

* **Error 2: Violación de Permisos (Modificador onlyOwner)**
    * **Cuenta:** Cuenta B (Carlos).
    * **Acción:** Intenta llamar a `resolverEvento`.
    * **Resultado:** La transacción revierte con el mensaje "Solo el owner de la casa puede hacer esto".
    ![Captura: Error por permisos de Owner en la consola de Remix](Ruta/A/Tu/Captura_ErrorOwner.png)

## 6. Resolución y Reparto de Premios
El dueño finaliza el evento y el contrato reparte automáticamente las ganancias.

* **Cuenta utilizada:** Cuenta A (Owner)
* **Acción:** Llamada a `resolverEvento(1, true)` (Gana el equipo A).
* **Resultado:** Como la Cuenta B acertó, la Casa de Apuestas llama a `ownerMint` para devolverle su ficha apostada más su beneficio correspondiente.
* **Logs:** Se emiten los eventos `EventoResuelto` y `PremioRepartido`.

![Captura: Evento finalizado y reparto de premios (mint a favor del ganador)](Ruta/A/Tu/Captura_ResolverEvento.png)