export type ThermostatScriptData = {
  readonly trace: readonly { readonly line: number; readonly values: readonly (number | null)[]; readonly condition: boolean; readonly output: string | null }[];
  readonly closing: string;
  readonly start: number;
  readonly step: number;
  readonly lineHeight: number;
  readonly codeY: number;
  readonly limit: number;
  readonly tail: { readonly start: number; readonly end: number };
  readonly lockup: number;
  readonly colors: { readonly code: string; readonly current: string; readonly number: string; readonly reached: string; readonly bar: string; readonly conditionBar: string };
};

const HELPERS = `const clamp=(x)=>x<0?0:x>1?1:x, ease=(x)=>{x=clamp(x);return x*x*(3-2*x);};
const END=D.start+D.trace.length*D.step;
function stepAt(t){return Math.max(0,Math.min(D.trace.length-1,Math.floor((t-D.start)/D.step)));}
function fadeCode(t){return 1-ease((t-END-0.4)/0.9);}`;

const CODE = `function renderCode(t,i,k){
  const s=D.trace[i],prev=D.trace[Math.max(0,i-1)],active=t>=D.start&&t<END+0.6,fade=fadeCode(t);
  document.querySelectorAll(".line").forEach((n,j)=>{const on=j===s.line&&active;n.style.opacity=String((on?1:0.42)*fade);n.style.color=on?D.colors.current:D.colors.code;});
  const bar=document.getElementById("bar"),y0=D.codeY+prev.line*D.lineHeight,y1=D.codeY+s.line*D.lineHeight;
  bar.style.top=(y0+(y1-y0)*k-8)+"px";bar.style.opacity=String((active?1:0)*fade);bar.style.background=s.condition?D.colors.conditionBar:D.colors.bar;
  const lines=D.trace.slice(0,i+1).filter((x,j)=>t>=D.start&&x.output&&j<D.trace.length-1).map((x)=>"<div>"+x.output+"</div>");
  const out=document.getElementById("out");out.innerHTML=lines.join("");out.style.opacity=String(fade);
}`;

const NUMBERS = `function renderNumbers(t,i,k){
  const s=D.trace[i],prev=D.trace[Math.max(0,i-1)],fade=fadeCode(t)*ease((t-0.3)/0.8);
  document.querySelectorAll(".value").forEach((n,v)=>{
    const now=s.values[v],before=prev.values[v],changed=i>0&&now!==before&&t>=D.start;
    const shown=t<D.start||now===null?(v===0?D.trace[0].values[0]:null):(changed&&k<0.5?before:now);
    n.textContent=shown===null?"–":String(shown);
    n.style.transform="translateY("+(changed?(k<0.5?-k:(1-k))*n.offsetHeight*0.2:0)+"px)";
    n.style.opacity=String((changed?Math.abs(1-2*k)*0.6+0.4:1)*fade);
    n.style.color=v===0&&now!==null&&now<=D.limit?D.colors.reached:D.colors.number;});
  document.querySelectorAll(".label").forEach((n)=>n.style.opacity=String(0.8*fade));
}`;

const ENDING = `function renderEnding(t){
  const fin=document.getElementById("closing");fin.style.opacity=String(ease((t-END-1.2)/0.6)*(1-ease((t-D.tail.start+0.2)/0.6)));
  const tail=document.getElementById("tail");tail.style.opacity=String(ease((t-D.tail.start)/0.5)*(1-ease((t-D.tail.end+0.5)/0.5)));
  document.getElementById("lockup").style.opacity=String(ease((t-D.lockup)/1.0));
}
function render(t){const i=stepAt(t),k=ease((t-D.start-i*D.step)/0.35);renderCode(t,i,k);renderNumbers(t,i,k);renderEnding(t);}`;

export function thermostatScript(data: ThermostatScriptData): string {
  return `const D=${JSON.stringify(data)};\n${HELPERS}\n${CODE}\n${NUMBERS}\n${ENDING}`;
}
