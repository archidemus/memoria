geth --datadir ./node3/ init ./itemtracking.json && geth --datadir ./node3/ --syncmode 'full' --port 30313 --rpc --rpcaddr 'localhost' --rpcport 8503 --rpcapi 'personal,db,eth,net,web3,txpool,miner' --bootnodes 'enode://fc787f2bf390a6409b0fdd2b91b886059f5bac4ec40de97388398c1c257cab458fffd387b0e83ff3ce0b82ddb96c7f3530c386038b5f5262603045731e352a10@127.0.0.1:30311' --networkid 23451 --gasprice '0' -unlock '0x64dab98d1ff5ba70b3911f22cfd4d93391a23991, 0x9db9465b985dc091975046ef1ec7cda8f65e4542' --password ./password.txt --mine --allow-insecure-unlock
