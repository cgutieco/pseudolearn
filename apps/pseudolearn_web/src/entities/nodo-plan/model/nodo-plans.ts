export interface NodoPlans {
  readonly trial: { readonly days: number; readonly credits: number };
  readonly monthly: { readonly credits: number };
  readonly topUp: { readonly credits: number };
  readonly minimumAge: number;
}

export const NODO_PLANS: NodoPlans = {
  trial: { days: 7, credits: 40 },
  monthly: { credits: 300 },
  topUp: { credits: 150 },
  minimumAge: 13,
};
