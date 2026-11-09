import {
  type CheckoutStatus,
  initialStatusOf,
  paddleEnvironmentOf,
  statusAfterEvent,
} from './checkout-status';

const SCRIPT_URL = 'https://cdn.paddle.com/paddle/v2/paddle.js';

interface PaddleEvent {
  readonly name?: string;
}

interface PaddleApi {
  Environment: { set(environment: string): void };
  Initialize(options: { token: string; eventCallback: (event: PaddleEvent) => void }): void;
}

declare global {
  interface Window {
    Paddle?: PaddleApi;
  }
}

function loadPaddle(): Promise<PaddleApi | null> {
  return new Promise((resolve) => {
    const script = document.createElement('script');
    script.src = SCRIPT_URL;
    script.async = true;
    script.onload = () => resolve(window.Paddle ?? null);
    script.onerror = () => resolve(null);
    document.head.append(script);
  });
}

function show(root: HTMLElement, status: CheckoutStatus): void {
  root.dataset.checkoutStatus = status;
  for (const message of root.querySelectorAll<HTMLElement>('[data-checkout-message]')) {
    message.hidden = message.dataset.checkoutMessage !== status;
  }
  const returnLink = root.querySelector<HTMLElement>('[data-checkout-return]');
  if (returnLink) returnLink.hidden = status !== 'completed' && status !== 'closed';
}

export function attachPaddleCheckout(document: Document): void {
  const root = document.querySelector<HTMLElement>('[data-paddle-checkout]');
  if (!root) return;
  let status = initialStatusOf(window.location.search);
  show(root, status);
  const token = root.dataset.paddleToken ?? '';
  if (status !== 'loading') return;
  if (token === '') return show(root, 'unavailable');
  void loadPaddle().then((paddle) => {
    if (!paddle) return show(root, 'unavailable');
    paddle.Environment.set(paddleEnvironmentOf(root.dataset.paddleEnvironment ?? ''));
    paddle.Initialize({
      token,
      eventCallback: (event) => {
        status = statusAfterEvent(status, event.name ?? '');
        show(root, status);
      },
    });
  });
}
