import Fastify from 'fastify';
import fs from 'fs';
import FlowCLI from './source/FlowCLI.js';

(async () => {
  // 0: 0111010011101011100101110
  // 1: 0010001100001000010001110
  // 2: 0111010001000100010011111
  // 3: 0111010001001101000101110
  // 4: 0011001010100101111100010
  // 5: 1111110000111100000111110
  // 6: 0111110000111101000101110
  // 7: 1111100010111110100010000
  // 8: 0111010001011101000101110
  // 9: 0111010001011100000111110

  // A: 0111010001111111000110001
  // B: 1111010001111101000111110
  // C: 0111010001100001000101110
  // D: 1111010001100011000111110
  // E: 1111010000111001000011110
  // F: 1111010000111001000010000
  // G: 0111110000101111000101111
  // H: 1000110001111111000110001
  // I: 1111100100001000010011111
  // J: 0111000010000100101001110
  // K: 1000110010101001101010001
  // L: 1000010000100001000011111
  // M: 1000111011101011000110001
  // N: 1000111001101011001110001
  // O: 0111010001100011000101110
  // P:
  // Q:
  // R:
  // S:
  // T:
  // U:
  // V:
  // W: 1000110101101011111101010
  // X:
  // Y:
  // Z:

  const letterX = [
    '10001',
    '01010',
    '00100',
    '01010',
    '10000'
  ];

  // await FlowCLI.executeTransaction({
  //   transactionPath: './model/Artist/transactions/printPicture.cdc',
  //   argsJSON: [
  //     {
  //       type: 'String',
  //       value: letterX.join('')
  //     }
  //   ],
  //   authorizer: 'owner',
  //   proposer: 'owner',
  //   payer: 'owner',
  //   network: 'emulator',
  //   showOutput: true
  // });
  // await FlowCLI.executeTransaction({
  //   transactionPath: 'model/PictureNFT/transactions/createCollection.cdc',
  //   authorizer: 'user-testnet',
  //   proposer: 'user-testnet',
  //   payer: 'user-testnet',
  //   network: 'testnet'
  // });
  // await FlowCLI.executeScript({
  //   scriptPath: 'model/Artist/scripts/getCanvases.cdc',
  //   argsJSON: [
  //     {
  //       type: 'Address',
  //       value: '0x01cf0e2f2f715450'
  //     }
  //   ],
  //   network: 'emulator',
  // });

  const fastify = Fastify({
    logger: true
  });

  fastify.get('/', async (request, reply) => {
    reply
      .type('text/html')
      .send(fs.readFileSync('./main.html', 'utf-8'));
  });
  fastify.listen(3200, '0.0.0.0', (error, address) => {
    if (error) {
      console.log(error);
      process.exit(1);
    } else {
      fastify.log.info(`Server listening on ${address}.`);
    }
  });
})();