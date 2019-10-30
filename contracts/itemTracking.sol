pragma solidity 0.5.10;

contract ItemTrackingContract {

    enum assetsStatus {ACTIVE, PENDING, INACTIVE}

    address constant owner1 = address(0xcF9D370f9f6F2F99DD3d5FFab98cb3943F097461);
    address constant admin1 = address(0x97deC0F7f29A571E4C730234073dF151A34Da016);
    address constant admin2 = address(0x97E3957dBa309E2a7558bA76F0b7558676CAAa33);
    address constant admin3 = address(0x794B44D6B775343Fc3a75f4213635B5f9268f9f7);
    address constant user1 = address(0x28542774261bF85100bd2B8D3b7Ed2dD75a44ab2);
    address constant user2 = address(0x4A0dE930Dc9E44F15BeBcC124e8F0eB5a1f1df88);
    address constant user3 = address(0x61C2254B3FF6BaBC6989aFc4915207D027F7d9D0);
    address constant user4 = address(0x09ED5Be77368de70E6c480E46644777e80158a5d);
    address constant user5 = address(0x9E319c14eDE476EA4F3D62C02faDD1BC0eDd121c);
    address constant user6 = address(0xffD6980738433c3C8c1060438971e4F3DAE404a3);

    struct Disposal {
        uint[] creators;
        uint toContainer;
        uint quantity;
        uint itemId;
    }

    struct Trespassing {
        uint[] creators;
        uint fromContainer;
        uint toContainer;
        uint quantity;
    }

    struct Transformation {
        uint[] creators;
        uint fromContainer;
        uint quantity;
        uint toProduct;
    }

    struct Stage {
        uint[] containers;
        uint[] products;
    }

    struct User {
        assetsStatus status;
        address userAddress;
        uint[] deliveries;
    }

    struct Item {
        uint[] creators;
        uint[] nextItems;
        uint previousItem;
        uint quantity;
    }

    struct Container {
        uint[] activeItems;
        uint quantity;
        uint[] lastResponsables;
    }

    struct Product {
        uint[] items;
    }

    //Administration
    mapping(address => assetsStatus) public adminsStatus;
    address owner;

    //Containers
    mapping(uint => Container) containers;
    mapping(uint => uint) public containerStage;
    uint containerCount = 1;

    //Items
    mapping(uint => Item) public items;
    mapping(uint => uint) public itemContainer;
    mapping(uint => uint) public itemDisposal;
    mapping(uint => uint) public itemProduct;
    uint itemCount = 1;

    //Users
    mapping(uint => User) public users;
    mapping(address => uint) public addressToUser;
    uint userCount = 1;

    //Stages
    mapping(uint => Stage) stages;
    uint stageCount = 1;

    //Product
    mapping(uint => Product) products;
    mapping(uint => uint) public productStage;
    uint productCount = 1;

    //Disposal
    mapping(uint => Disposal) disposals;
    uint disposalCount = 1;

    //Trespassing
    mapping(uint => Trespassing) trespassings;
    uint trespassingCount = 1;

    //Transformation
    mapping(uint => Transformation) transformations;
    uint transformationCount = 1;

    //Modifiers
    modifier validAddress(address sender) {
        require(sender != address(0), "Must be valid address");
        _;
    }

    modifier isAdmin(address sender) {
        require(adminsStatus[sender] == assetsStatus.ACTIVE, "Must be admin");
        _;
    }

    modifier notAdmin(address sender) {
        require(adminsStatus[sender] != assetsStatus.ACTIVE, "Shouldn't be admin");
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    modifier itemsExist(uint[] memory _items) {
        for(uint i = 1; i < _items.length; i++) {
            require(_items[i] < itemCount, "All items must exist");
        }
    _;
    }

    modifier itemExist(uint _itemId) {
        require(_itemId < itemCount, "Item must exist");
    _;
    }

    modifier containerExist(uint _containerId) {
        require(_containerId < containerCount, "Container must exist");
    _;
    }

    modifier productExist(uint _productId) {
        require(_productId < productCount || _productId != 0, "Product must exist");
    _;
    }

    modifier isUser(address user) {
        uint userId = addressToUser[user];
        require(users[userId].status == assetsStatus.ACTIVE, "Must be an active user");
        _;
    }

    //Logic
    constructor() public validAddress(msg.sender) {
        owner = msg.sender;
        adminsStatus[owner] = assetsStatus.ACTIVE;

        createStage();
        createStage();
        createStage();
        createStage();
        createStage();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        createContainer();
        addContainerToStage(1,1);
        addContainerToStage(1,9);
        addContainerToStage(2,4);
        addContainerToStage(2,3);
        addContainerToStage(2,2);
        addContainerToStage(3,6);
        addContainerToStage(3,5);
        addContainerToStage(4,7);
        addContainerToStage(4,8);
        addAdmin(admin1);
        addAdmin(admin2);
        addAdmin(admin3);
        createUser(user1);
        createUser(user2);
        createUser(user3);
        createUser(user4);
        createUser(user5);
        createUser(user6);
    }

    function addAdmin(address _newAdmin)  public isOwner() {
        adminsStatus[_newAdmin] = assetsStatus.ACTIVE;
    }

    function createContainer() public isAdmin(msg.sender) returns (uint containerId){
        containerId = containerCount;
        containerCount++;
        uint[] memory newItems;
        uint[] memory creator;
        containers[containerId] = Container(newItems, 0, creator);
        containers[containerId].lastResponsables.push(addressToUser[msg.sender]);
    }

    function createItem(
        uint[] memory _creators,
        uint[] memory _nextItems,
        uint _previousItem,
        uint _quantity
    ) public isAdmin(msg.sender) returns (
        uint itemId
    ){
        itemId = itemCount;
        itemCount++;
        Item memory item;
        item.creators = _creators;
        item.nextItems = _nextItems;
        item.previousItem = _previousItem;
        item.quantity = _quantity;
        items[itemId] = item;
    }

    function addItemToContainer(uint _itemId, uint _containerId) public {
        containers[_containerId].activeItems.push(_itemId);
        containers[_containerId].quantity += items[_itemId].quantity;
        itemContainer[_itemId] = _containerId;
    }

    function getItem(
        uint _itemId
    ) public view itemExist(_itemId) returns(
        uint[] memory creators_,
        uint[] memory nextItems_,
        uint previousItem_,
        uint quantity_
    ){
        creators_ = items[_itemId].creators;
        nextItems_ = items[_itemId].nextItems;
        previousItem_ = items[_itemId].previousItem;
        quantity_ = items[_itemId].quantity;
    }

    function updateContainerRemoveItems(uint[] memory _activeItemsId, uint _containerId, uint _quantity) public {
        containers[_containerId].activeItems = _activeItemsId;
        containers[_containerId].quantity -= _quantity;
    }

    function createUser(address _userAddress) public isAdmin(msg.sender) {
        uint userId = userCount;
        userCount++;
        uint[] memory userDeliveries;
        users[userId] = User(assetsStatus.ACTIVE, _userAddress, userDeliveries);
    }

    function createStage() public isAdmin(msg.sender) {
        uint stageId = stageCount;
        stageCount++;
        uint[] memory emptyArray;
        stages[stageId] = Stage(emptyArray, emptyArray);
    }

    function addContainerToStage(uint _stageId, uint _containerId) public isAdmin(msg.sender){
        stages[_stageId].containers.push(_containerId);
        containerStage[_containerId] = _stageId;
    }

    function createProduct() public isAdmin(msg.sender) returns (uint productId) {
        productId = productCount;
        productCount++;
        uint[] memory newItems;
        products[productId] = Product(newItems);
        stages[5].products.push(productId);
    }

    function addItemToProduct(uint _productId, uint _itemId) public itemExist(_itemId) productExist(_productId) isAdmin(msg.sender) {
        products[_productId].items.push(_itemId);
        itemProduct[_itemId] = _productId;
    }

    function getContainer(uint _containerId) public view returns (uint[] memory activeItems, uint quantity_, uint[] memory lastResponsables_) {
        activeItems = containers[_containerId].activeItems;
        quantity_ = containers[_containerId].quantity;
        lastResponsables_ = containers[_containerId].lastResponsables;
    }

    function getStage(uint _stageId) public view returns (uint[] memory containers_, uint[] memory products_) {
        containers_ = stages[_stageId].containers;
        products_ = stages[_stageId].products;
    }

    function getProduct(uint _productId) public view productExist(_productId) returns (uint[] memory items_) {
        items_ = products[_productId].items;
    }

    function createDisposal(
        uint[] memory _creators,
        uint _toContainer,
        uint _quantity
    ) public isAdmin(msg.sender) containerExist(_toContainer) returns (
        uint disposalId
    ) {
        uint[] memory emptyArray;
        uint itemId = createItem(_creators, emptyArray, 0, _quantity);
        addItemToContainer(itemId, _toContainer);
        disposalId = disposalCount;
        disposalCount++;
        disposals[disposalId] = Disposal(_creators, _toContainer, _quantity, itemId);
        itemDisposal[itemId] = disposalId;
        containers[_toContainer].lastResponsables = _creators;
    }

    function getDisposal(uint _disposalId) public view returns (
        uint[] memory creators_,
        uint toContainer,
        uint quantity_,
        uint itemId
        ) {
        creators_ = disposals[_disposalId].creators;
        toContainer = disposals[_disposalId].toContainer;
        quantity_ = disposals[_disposalId].quantity;
        itemId = disposals[_disposalId].itemId;
    }

    function createTrespassing(
        uint[] memory _creators,
        uint _fromContainer,
        uint _toContainer,
        uint _quantityTrespassed,
        uint[] memory _fromContainerActiveItems,
        uint[] memory _quantity,
        uint[] memory _trespassedItems
        ) public isAdmin(msg.sender) returns (
            uint trespassingId
        ) {
        uint[] memory emptyArray;
        for(uint i = 0; i < _trespassedItems.length; i++) {
            uint newItemId = createItem(_creators, emptyArray, _trespassedItems[i], _quantity[i]);
            addItemToContainer(newItemId, _toContainer);
            items[_trespassedItems[i]].nextItems.push(newItemId);
            items[_trespassedItems[i]].quantity -= _quantity[i];
        }
        updateContainerRemoveItems(_fromContainerActiveItems, _fromContainer, _quantityTrespassed);
        trespassingId = trespassingCount;
        trespassingCount++;
        trespassings[trespassingId] = Trespassing(_creators, _fromContainer, _toContainer, _quantityTrespassed);
        containers[_toContainer].lastResponsables = _creators;
        containers[_fromContainer].lastResponsables = _creators;
    }

    function createTransformation(
        uint[] memory _creators,
        uint _fromContainer,
        uint _toProduct,
        uint _quantityTransformed,
        uint[] memory _fromContainerActiveItems,
        uint[] memory _quantity,
        uint[] memory _transformedItems
        ) public isAdmin(msg.sender) returns (
            uint transformationId
        ) {
        uint toProduct = _toProduct;
        uint[] memory emptyArray;
        if (toProduct == 0) {
            toProduct = createProduct();
            productStage[toProduct] = 5;
        }
        for(uint i = 0; i < _transformedItems.length; i++) {
            uint newItemId = createItem(_creators, emptyArray, _transformedItems[i], _quantity[i]);
            addItemToProduct(toProduct, newItemId);
            items[_transformedItems[i]].nextItems.push(newItemId);
            items[_transformedItems[i]].quantity -= _quantity[i];
            products[toProduct].items.push(newItemId);
        }
        updateContainerRemoveItems(_fromContainerActiveItems, _fromContainer, _quantityTransformed);
        transformationId = transformationCount;
        transformationCount++;
        transformations[transformationId] = Transformation(_creators, _fromContainer, _quantityTransformed, toProduct);
        containers[_fromContainer].lastResponsables = _creators;
    }
}