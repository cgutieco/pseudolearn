function syncPicture(picture: HTMLElement, forced: string | undefined): void {
  for (const source of picture.querySelectorAll<HTMLSourceElement>('source')) {
    const base = source.dataset.query === 'all' ? '' : (source.dataset.query ?? '');
    const scheme = source.dataset.scheme ?? 'light';
    if (!forced) {
      const preference = `(prefers-color-scheme: ${scheme})`;
      source.media = base ? `${base} and ${preference}` : preference;
    } else {
      source.media = forced === scheme ? base || 'all' : 'not all';
    }
  }
}

export function syncProductPictures(): void {
  const pictures = document.querySelectorAll<HTMLElement>('[data-product-preview]');
  const sync = () => {
    for (const picture of pictures) syncPicture(picture, document.documentElement.dataset.theme);
  };
  new MutationObserver(sync).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['data-theme'],
  });
  sync();
}
