import {spawn} from 'child_process';
import fs from 'fs';

const constants = {
  temporaryStorage: './temporary'
};

class FlowCLI {
  static wrap(argumentsCLI = [], showOutput = false) {
    return () => new Promise((resolve, reject) => {
      const flow = spawn(
        'flow',
        argumentsCLI
      );
  
      flow.stdout.on('data', (data) => {
        if (showOutput) {
          console.log(data);
        }
      });
      flow.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
      });
      flow.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(code);
        }
      });
    });
  }
  static async executeTransaction(transactionPath) {
    const timestamp = Date.now();
    const builtPath = `${constants.temporaryStorage}/built.${timestamp}.rlp`;
    const signedPath = `${constants.temporaryStorage}/signed.${timestamp}.rlp`;

    const build = FlowCLI.wrap([
      'transactions',
      'build',
      transactionPath,
      '--authorizer=owner',
      '--proposer=owner',
      '--payer=owner',
      '--filter=payload',
      `--save=${builtPath}`
    ]);
    const sign = FlowCLI.wrap([
      'transactions',
      'sign',
      builtPath,
      '--signer=owner',
      '--filter=payload',
      `--save=${signedPath}`,
      '-y'
    ]);
    const send = FlowCLI.wrap([
      'transactions',
      'send-signed',
      signedPath
    ]);

    try {
      await build();
      await sign();
      await send();

      fs.unlinkSync(builtPath);
      fs.unlinkSync(signedPath);
    } catch (error) {
      console.error(error);
    }
  }
}

export {FlowCLI as default};