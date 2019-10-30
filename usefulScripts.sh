#Crear accounts. Genera archivo keystore. password.txt contiene la clave privada del usuario, escogida por uno. Guardar accounts en accounts.txt es opcional.
geth --datadir node1/ account new --password password.txt

#Crear genesis block
puppeth

#Inicializar nodos
geth --datadir node1/ init itemtracking.json
geth --datadir node2/ init itemtracking.json

#Crear key para enode fijo del bootnode
bootnode -genkey boot.key

#Iniciar bootnode. Para mantener la misma direccion se usa el archivo bootnode.
geth --datadir ./node1/ init ./itemtracking.json && geth --datadir ./node1/ --syncmode 'full' --port 30311 --rpc --rpcaddr 'localhost' --rpcport 8501 --rpcapi 'personal,db,eth,net,web3,txpool,miner' --networkid 23451 --gasprice '1' -unlock '0xcF9D370f9f6F2F99DD3d5FFab98cb3943F097461, 0x97deC0F7f29A571E4C730234073dF151A34Da016' --password ./password.txt --mine --allow-insecure-unlock --nodekey ./boot.key

#Iniciar nodo general. Apunta al bootnode fijo.
geth --datadir node2/ --syncmode 'full' --port 30312 --rpc --rpcaddr 'localhost' --rpcport 8502 --rpcapi 'personal,db,eth,net,web3,txpool,miner' --bootnodes 'enode://fc787f2bf390a6409b0fdd2b91b886059f5bac4ec40de97388398c1c257cab458fffd387b0e83ff3ce0b82ddb96c7f3530c386038b5f5262603045731e352a10@127.0.0.1:0?discport=30310' --networkid 23451 --gasprice '1' -unlock '0x97E3957dBa309E2a7558bA76F0b7558676CAAa33, 0x794B44D6B775343Fc3a75f4213635B5f9268f9f7, 0x28542774261bF85100bd2B8D3b7Ed2dD75a44ab2, 0x4A0dE930Dc9E44F15BeBcC124e8F0eB5a1f1df88, 0x61C2254B3FF6BaBC6989aFc4915207D027F7d9D0, 0x09ED5Be77368de70E6c480E46644777e80158a5d, 0x9E319c14eDE476EA4F3D62C02faDD1BC0eDd121c, 0xffD6980738433c3C8c1060438971e4F3DAE404a3' --password password.txt --mine --allow-insecure-unlock

#Acceder a la consola del nodo
geth attach ipc:node1/geth.ipc

#Propone un nuevo firmante. Para que sea efectivo debe realizarlo mas del 50% de los nodos
clique.propose("0x64dab98d1ff5ba70b3911f22cfd4d93391a23991", true)

#Lista los firmantes.
clique.getSigners()

#Comprobar si se sigue sincronizando el nodo. Si retorna false, termino.
web3.eth.syncing

#Obtiene el balance de una cuenta.
web3.eth.getBalance(walletAddress);