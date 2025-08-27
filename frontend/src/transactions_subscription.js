// transactions_subscription.js - subscribes to the transactions channel
import cable from './cable';

export function subscribeToTransactions({ onCreate, onUpdate, onDestroy }) {
  const subscription = cable.subscriptions.create(
    { channel: 'TransactionsChannel' },
    {
      received(data) {
        if (data.action === 'created' && onCreate) onCreate(data.transaction);
        if (data.action === 'updated' && onUpdate) onUpdate(data.transaction);
        if (data.action === 'destroyed' && onDestroy) onDestroy(data.id);
      }
    }
  );
  return subscription;
}
