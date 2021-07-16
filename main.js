import FlowCLI from './source/FlowCLI.js';

(async () => {
  await FlowCLI.executeTransaction('./transactions/test.cdc');
})();