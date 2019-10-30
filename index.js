const Config = require("./config.js");

let statistics = {
  total: {
    time: 0,
    gas: 0,
  },
  transactions: {
    time: 0,
    gas: 0,
    details: []
  },
  calls: {
    time: 0,
    details: []
  }
}

startContract  = async () => {
  config = await Config();
  contract = config.contract;
  web3 = config.web3;
  accounts = config.accounts;

  for (let i = 0; i <= 100; i += 1) {
    await dispose([3], 1, 10);
    await dispose([4, 1], 9, 18);
  }
  await trespassing([5], 1, 4, 1);
  await trespassing([2], 1, 3, 9);
  await trespassing([5], 9, 3, 10);
  await trespassing([2], 9, 2, 6);
  await trespassing([1, 5], 3, 5, 11);
  await trespassing([1], 5, 6, 9);
  await trespassing([1], 6, 7, 8);
  await trespassing([1, 2], 2, 5, 6);
  await trespassing([5], 4, 6, 1);
  await trespassing([1, 2], 5, 8, 5);
  await trespassing([3], 8, 7, 2);
  await transformation([5], 7, 10);
  await transformation([1], 8, 2, 1);
  await stageStatus(1);
  await stageStatus(2);
  await stageStatus(3);
  await stageStatus(4);
  await stageStatus(5);
  await disposalStatus(1);
  await disposalStatus(2);
  await containerStatus(1);
  await containerStatus(2);
  await containerStatus(3);
  await containerStatus(4);
  await containerStatus(5);
  await containerStatus(6);
  await containerStatus(7);
  await containerStatus(8);
  await containerStatus(9);
  await historyOfProduct(1);
  await containerLastResponsables(5);

  console.log("statistics", JSON.stringify(statistics));

}

dispose = async (creators, toContainer, quantity) => {
  await doTransaction('createDisposal', {creators, toContainer, quantity}, eval("accounts.user"+creators[0]), true)
};

trespassing = async (creators, fromContainer, toContainer, quantity) => {
  const containerFrom = await doTransaction('getContainer', {fromContainer}, eval("accounts.user"+creators[0]))
  const trespassedItems = [];
  const trespassedQuantity = [];
  const fromContainerActiveItems = [];
  let totalTrespassed = 0;

  for (let i = 0; i < containerFrom.activeItems.length; i++) {
    const activeItem = containerFrom.activeItems[i];
    const itemQuantity =  Number ((await doTransaction('items', {activeItem}, eval("accounts.user"+creators[0]))).quantity);
    if (totalTrespassed >= quantity){
      fromContainerActiveItems.push(containerFrom.activeItems[i])
    } else {
      trespassedItems.push(containerFrom.activeItems[i]);
      if (totalTrespassed + itemQuantity > quantity) {
        trespassedQuantity.push(quantity - totalTrespassed);
        fromContainerActiveItems.push(containerFrom.activeItems[i])
      } else {
        trespassedQuantity.push(itemQuantity);
      }
    }
    totalTrespassed = totalTrespassed + itemQuantity;
  }
  await doTransaction('createTrespassing', {creators, fromContainer, toContainer, quantity, fromContainerActiveItems, trespassedQuantity, trespassedItems}, eval("accounts.user"+creators[0]), true);
};

transformation = async (creators, fromContainer, quantity, toProduct = 0) => {
  const containerFrom = await doTransaction('getContainer', {fromContainer}, eval("accounts.user"+creators[0]))
  const transformedItems = [];
  const transformedQuantity = [];
  const fromContainerActiveItems = [];

  let totalTransformed = 0;

  for (let i = 0; i < containerFrom.activeItems.length; i++) {
    const activeItem = containerFrom.activeItems[i];
    const itemQuantity = Number ((await doTransaction('items', {activeItem}, eval("accounts.user"+creators[0]))).quantity);
    if (totalTransformed >= quantity){
      fromContainerActiveItems.push(containerFrom.activeItems[i])
    } else {
      transformedItems.push(containerFrom.activeItems[i]);
      if (totalTransformed + itemQuantity > quantity) {
        transformedQuantity.push(quantity - totalTransformed);
        fromContainerActiveItems.push(containerFrom.activeItems[i])
      } else {
        transformedQuantity.push(itemQuantity);
      }
    }
    totalTransformed = totalTransformed + itemQuantity;
  }
  await doTransaction('createTransformation', {creators, fromContainer, toProduct, quantity, fromContainerActiveItems, transformedQuantity, transformedItems}, eval("accounts.user"+creators[0]), true);
}

stageStatus = async (stageId) => {
  console.log("stageStatus -> stageId", stageId)
  let status = {"containers": {}, "products": {}};
  const stage = await doTransaction('getStage', {stageId}, accounts.owner1);
  for (containerId of stage.containers_) {
    status["containers"][containerId] = {};
    const container = await doTransaction('getContainer', {containerId}, accounts.owner1);
    for (itemId of container.activeItems) {
      item = await doTransaction('items', {itemId}, accounts.owner1);
      status['containers'][containerId][itemId] = {previousItems: item.previousItem, quantity: item.quantity};
    }
  }

  for (productId of stage.products_) {
    status["products"][productId] = {};
    const product = await doTransaction('getProduct', {productId}, accounts.owner1);
    for (itemId of product) {
      item = await doTransaction('items', {itemId}, accounts.owner1);
      status["products"][productId][itemId] = {previousItems: item.previousItem, quantity: item.quantity};
    }
  }
  console.log("status", JSON.stringify(status))
  return status;
}

disposalStatus = async (disposalId) => {
  console.log("disposalStatus -> disposalId", disposalId)
  const disposalItem = await doTransaction('getDisposal', {disposalId}, accounts.owner1);
  let itemsQueue = [disposalItem.itemId];
  let disposalStatus = {};
  while (itemsQueue.length > 0){
    let itemId = itemsQueue.pop();
    let item = await doTransaction('getItem', {itemId}, accounts.owner1);
    if (item.nextItems_.length > 0) {
      itemsQueue = itemsQueue.concat(item.nextItems_);
    }

    if (Number(item.quantity_) > 0) {
      let container = await doTransaction('itemContainer', {itemId}, accounts.owner1);
      if (container === "0") {
        let product = await doTransaction('itemProduct', {itemId}, accounts.owner1);
        let stage = await doTransaction('productStage', {product}, accounts.owner1);
        disposalStatus[itemId] = {"stage": stage, "container": null,"product": product};
      } else {
        let stage = await doTransaction('containerStage', {container}, accounts.owner1);
        disposalStatus[itemId] = {"stage": stage, "container": container, "product": null};
      }
    }
  }
  console.log("disposalStatus", disposalStatus)
}

containerStatus = async (containerId) => {
  console.log("containerStatus -> containerId", containerId)
  const containerStatus = {};
  const container = await doTransaction('getContainer', {containerId}, accounts.owner1);
  for (itemId of container.activeItems) {
    const item = await doTransaction('items', {itemId}, accounts.owner1);
    containerStatus[itemId] = {previousItems: item.previousItem, quantity: item.quantity};
  }
  console.log("containerStatus", containerStatus)
}

historyOfProduct = async (productId) => {
  console.log("historyOfProduct -> productId", productId)
  const historyOfProduct = {};
  let productItemsId = await doTransaction('getProduct', {productId}, accounts.owner1);
  for (productItemId of productItemsId) {
    historyOfProduct[productItemId] = {};
    const productItem = await doTransaction('getItem', {productItemId}, accounts.owner1);
    let itemReviewedId = productItem.previousItem_;
    do {
      let itemReviewedContainerId = await doTransaction('itemContainer', {itemReviewedId}, accounts.owner1);
      let itemReviewedStageId = await doTransaction('containerStage', {itemReviewedContainerId}, accounts.owner1);

      historyOfProduct[productItemId][itemReviewedId] = {
        container: itemReviewedContainerId,
        stage: itemReviewedStageId
      }

      let itemReviewed = await doTransaction('getItem', {itemReviewedId}, accounts.owner1);
      itemReviewedId = itemReviewed.previousItem_;
    }
    while (itemReviewedId !== "0");
  }

  console.log("historyOfProduct", historyOfProduct)
}

containerLastResponsables = async (containerId) => {
  console.log("containerLastResponsables -> containerId", containerId)
  const container = await doTransaction('getContainer', {containerId, containerId}, accounts.owner1);
  console.log("containerLastResponsables", container.lastResponsables_)
  return container.lastResponsables_;
}

doTransaction = async (method, arguments, account, transaction = false) => {
  let parameters = "";
  for (argument in arguments) {
    parameters = parameters + " arguments." + argument + ",";
  }
  parameters = parameters.replace(/\,$/, "");
  let methodString = "contract.methods." + method + "(" + parameters + ")";
  console.log(methodString)
  const assets = eval(methodString);
  const assetsEG = await assets.estimateGas();
  let result = {};
  if (transaction) {
    let t0 = (new Date).getTime();
    result =  await assets.send({from: account, gas: assetsEG, gasPrice: '0'});
    let t1 = (new Date).getTime();
    let miliseconds = (t1 - t0);
    statistics.total.time += miliseconds;
    statistics.total.gas += result.gasUsed;
    statistics.transactions.time += miliseconds;
    statistics.transactions.gas += result.gasUsed;
    statistics.transactions.details.push(
      {
        method: method,
        time: miliseconds,
        gas: result.gasUsed
      }
    )
  } else {
    let t0 = (new Date).getTime();
    result = await assets.call({from: account, gas: assetsEG});
    let t1 = (new Date).getTime();
    let miliseconds = (t1 - t0);
    statistics.total.time += miliseconds;
    statistics.calls.time += miliseconds;
    statistics.calls.details.push(
      {
        method: method,
        time: miliseconds,
      }
    )
  }
  return result;
}

startContract();