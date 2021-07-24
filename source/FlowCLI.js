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
        argumentsCLI.filter((argument) => argument && argument.length > 0)
      );
  
      flow.stdout.on('data', (data) => {
        if (showOutput) {
          console.log(`${data}`);
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
  static async executeTransaction(props) {
    const timestamp = Date.now();
    const builtPath = `${constants.temporaryStorage}/built.${timestamp}.rlp`;
    const signedPath = `${constants.temporaryStorage}/signed.${timestamp}.rlp`;
    
    const build = FlowCLI.wrap([
      'transactions',
      'build',
      props.transactionPath,
      props.argsJSON ? `--args-json=${JSON.stringify(props.argsJSON)}` : '',
      `--authorizer=${props.authorizer}`,
      `--proposer=${props.proposer}`,
      `--payer=${props.payer}`,
      '--filter=payload',
      `--save=${builtPath}`,
      `--network=${props.network || 'emulator'}`
    ], props.showOutput === true);
    const sign = FlowCLI.wrap([
      'transactions',
      'sign',
      builtPath,
      `--signer=${props.authorizer}`,
      '--filter=payload',
      `--save=${signedPath}`,
      `--network=${props.network || 'emulator'}`,
      '-y'
    ], props.showOutput === true);
    const send = FlowCLI.wrap([
      'transactions',
      'send-signed',
      `--network=${props.network || 'emulator'}`,
      signedPath
    ], props.showOutput === true);

    try {
      await build();
      await sign();
      await send();

      fs.unlinkSync(builtPath);
      fs.unlinkSync(signedPath);
      console.log('1');
    } catch (error) {
      console.error(error);
    }
  }
  static async executeScript(props) {
    const script = () => new Promise((resolve, reject) => {
      const args = [
        'scripts',
        'execute',
        props.scriptPath,
        '--output=json'
      ];
      if (props.argsJSON) {
        args.push(`--args-json=${JSON.stringify(props.argsJSON)}`);
      }
      if (props.network) {
        args.push(`--network=${props.network}`);
      }
      const flow = spawn('flow', args);
      let buffer = '';
  
      flow.stdout.on('data', (data) => {
        buffer += data.toString('utf-8');
      });
      flow.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
      });
      flow.on('close', (code) => {
        if (code === 0) {
          resolve(buffer);
        } else {
          reject(code);
        }
      });
    });

    try {
      const response = await script();
      const responseJSON = JSON.parse(response);
      console.log(responseJSON);
      console.log(responseJSON.value);
    } catch (error) {
      console.error(error);
    }
  }
}

export {FlowCLI as default};