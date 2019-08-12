import Crowdfund from "./truffle/contracts/Crowdfund.json";

const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:7545"
    }
  },

  // contracts to monitor
  contracts: [Crowdfund],
  events: {
    // monitor events
    Crowdfund: ["ProjectStarted"]
  }
};

export default options;
