#!/usr/bin/env python3
"""Export current compiled Red/Blue learnsets, including inherited options."""
from pathlib import Path
from collections import defaultdict
import csv
import html
import io
import re
import subprocess

ROOT=Path(__file__).resolve().parents[1]

def load(version):
    syms={name:(int(bank,16),int(address,16)) for bank,address,name in re.findall(r'^([\da-fA-F]+):([\da-fA-F]+) (\S+)',(ROOT/(version+'.sym')).read_text(),re.M)}
    rom=(ROOT/(version+'.gbc')).read_bytes()
    def data(label,n):
        bank,address=syms[label];offset=bank*16384+address-16384 if bank else address
        return rom[offset:offset+n]
    names=re.findall(r'^\s*db "([^"@]*)@"',(ROOT/'text/move_names.asm').read_text(),re.M)
    charmap={k:int(v,16) for k,v in re.findall(r'^charmap "([^"]+)", \$([\da-fA-F]+)',(ROOT/'charmap.asm').read_text(),re.M)}
    def encode(s):
        out=[]
        while s:
            key=next((k for k in sorted(charmap,key=len,reverse=True) if s.startswith(k)),None)
            assert key is not None,s
            out.append(charmap[key]);s=s[len(key):]
        return bytes(out)
    expected=b''.join(encode(n+'@') for n in names)
    assert data('MoveNames',len(expected))==expected,'compiled move names differ from source'
    def move(n):assert 1<=n<=len(names),n;return names[n-1].title()
    titles={int(r['dex']):r['name'] for r in csv.DictReader((ROOT/'docs/POKEMON-AVAILABILITY.csv').open())}
    types={int(v,16):k.title() for k,v in re.findall(r'^(\w+)\s+EQU \$([\da-fA-F]+)',(ROOT/'constants/type_constants.asm').read_text(),re.M)}
    order=data('PokedexOrder',190)
    assert sorted(n for n in order if n)==list(range(1,184))==sorted(titles)
    machines=list(data('TechnicalMachines',68));extra=data('ExtraTMCompatibilityTable',366)
    records=[]
    for dex in range(1,184):
        internal=order.index(dex)+1
        base=data('BaseStats',183*28)[(dex-1)*28:dex*28]
        assert base[0]==dex
        ptr=int.from_bytes(data('EvosMovesPointerTable',380)[(internal-1)*2:internal*2],'little')
        bank=syms['EvosMovesPointerTable'][0];offset=bank*16384+ptr-16384
        evolutions=[]
        while rom[offset]:
            method=rom[offset];assert method in (1,2,3)
            length=4 if method==2 else 3
            target=rom[offset+length-1];assert order[target-1]
            evolutions.append(order[target-1]);offset+=length
        offset+=1;learn=[]
        while rom[offset]:
            level,m=rom[offset:offset+2];assert 1<=level<=100
            learn.append((level,m));offset+=2
        assert learn==sorted(learn,key=lambda x:x[0]),dex
        start=[m for m in base[15:19] if m]
        legacy=int.from_bytes(base[20:27],'little');new=int.from_bytes(extra[(dex-1)*2:dex*2],'little')
        tm=[(i+1,machines[i]) for i in range(50) if legacy&(1<<i)]
        tm += [(i+51,machines[i+55]) for i in range(13) if new&(1<<i)]
        hm=[(i+1,machines[i+50]) for i in range(5) if legacy&(1<<(i+50))]
        for m in start+[m for _,m in learn+tm+hm]:move(m)
        records.append(dict(dex=dex,name=titles[dex],types=list(dict.fromkeys(types[t] for t in base[6:8])),start=start,learn=learn,tm=tm,hm=hm,evolutions=evolutions))
    parents=defaultdict(list)
    for r in records:
        for target in r['evolutions']:parents[target].append(r['dex'])
    def ancestors(dex,seen=None):
        seen=set() if seen is None else seen
        for parent in parents[dex]:
            assert parent!=dex
            if parent not in seen:seen.add(parent);ancestors(parent,seen)
        return seen
    for r in records:
        own=set(r['start'])|{m for _,m in r['learn']+r['tm']+r['hm']}
        inherited=defaultdict(list)
        for parent in sorted(ancestors(r['dex'])):
            p=records[parent-1]
            for m in p['start']:
                if m not in own:inherited[m].append(f"{p['name']} — starting move")
            for level,m in p['learn']:
                if m not in own:inherited[m].append(f"{p['name']} — Lv {level}")
            for kind in ('tm','hm'):
                for number,m in p[kind]:
                    if m not in own:inherited[m].append(f"{p['name']} — {kind.upper()}{number:02}")
        r['inherited']={m:sources for m,sources in sorted(inherited.items(),key=lambda x:move(x[0]))}
    return records,{i+1:move(i+1) for i in range(len(names))}

INTRO='''All 183 species, including the 21 unique variants and 11 additional species. Extracted from the compiled game tables, verified identical between Red and Blue. Names use the in-game move names, including renamed moves such as Twister, Chomp and Shell Smash.

Starting moves are the species’ base moves, not four automatic grants on evolution. Level-up entries are shown exactly as stored, including repeated starting moves and multiple moves at one level. TM01–TM63 and HM01–HM05 list that species’ own compatibility. A Pokémon has only four moves at once.

“Retained from earlier stages” lists additional moves absent from the current species’ own starting, level-up and machine lists. Learn these before evolving and keep them. Delaying evolution may be necessary. This is especially relevant to Eevee’s level-40 Charm: its evolutions can retain it, but cannot relearn it directly. Starting moves and eligible level-up moves are handled by the move relearner for the current species; earlier-stage-only moves are not automatically added to that list.

These are species learning pools. Moves copied temporarily with Mimic, Duplicate, Transform or other battle effects, and special trainer moveset overrides, are not species learnsets. Automatic transformation is a separate mechanic.'''

def markdown(records,names,revision):
    out=['# Every Pokémon’s movepool — Purple Iron','',f'Game snapshot: `{revision}` · 10 November 2026.','', '[Searchable/printable HTML](ALL-POKEMON-MOVEPOOLS.html) · [CSV spreadsheet](ALL-POKEMON-MOVEPOOLS.csv)','',INTRO,'','## Index','']
    out += [f"- [{r['dex']:03} · {r['name']}](#pokemon-{r['dex']:03})" for r in records]
    for r in records:
        out += ['',f'<a id="pokemon-{r["dex"]:03}"></a>',f"## {r['dex']:03} · {r['name']}",'','**Type:** '+ ' / '.join(r['types']),'','**Starting moves:** '+(', '.join(names[m] for m in r['start']) or 'None'),'', '**Level-up moves**','','| Level | Move |','|---:|---|']
        out += [f'| {level} | {names[m]} |' for level,m in r['learn']] or ['| — | None |']
        for kind in ('tm','hm'):
            out += ['',f'**{kind.upper()} compatibility:** '+('; '.join(f'{kind.upper()}{n:02} {names[m]}' for n,m in r[kind]) or 'None')]
        out += ['','**Retained from earlier stages:**']
        out += ['', '| Additional move | Learn before evolving |','|---|---|']+[f'| {names[m]} | '+ '; '.join(sources)+' |' for m,sources in r['inherited'].items()] if r['inherited'] else ['','None beyond the lists above.']
    return '\n'.join(out)+'\n'

def spreadsheet(records,names):
    out=io.StringIO();w=csv.writer(out);w.writerow(['Dex','Pokemon','Types','Starting moves','Level-up moves','TMs','HMs','Additional inherited moves'])
    for r in records:
        w.writerow([r['dex'],r['name'],' / '.join(r['types']),'; '.join(names[m] for m in r['start']),'; '.join(f'{lv}: {names[m]}' for lv,m in r['learn']),*['; '.join(f'{k.upper()}{n:02}: {names[m]}' for n,m in r[k]) for k in ('tm','hm')],'; '.join(names[m]+': '+', '.join(src) for m,src in r['inherited'].items())])
    return out.getvalue()

def webpage(records,names,revision):
    esc=html.escape;cards=[]
    for r in records:
        title=f"{r['dex']:03} · {r['name']}";typ=' / '.join(r['types'])
        parts=['<p><b>Starting moves:</b> '+esc(', '.join(names[m] for m in r['start']) or 'None')+'</p>','<h3>Level-up moves</h3><table><thead><tr><th>Level</th><th>Move</th></tr></thead><tbody>']
        parts += [f'<tr><td>{lv}</td><td>{esc(names[m])}</td></tr>' for lv,m in r['learn']] or ['<tr><td>—</td><td>None</td></tr>']
        parts += ['</tbody></table>']
        for k in ('tm','hm'):parts+=['<h3>'+k.upper()+' compatibility</h3><p>'+esc('; '.join(f'{k.upper()}{n:02} {names[m]}' for n,m in r[k]) or 'None')+'</p>']
        parts+=['<h3>Retained from earlier stages</h3>']
        parts+=['<ul>']+['<li><b>'+esc(names[m])+':</b> '+esc('; '.join(src))+'</li>' for m,src in r['inherited'].items()]+['</ul>'] if r['inherited'] else ['<p>None beyond the lists above.</p>']
        search=' '.join([title,typ,*[names[m] for m in r['start']],*[names[m] for _,m in r['learn']+r['tm']+r['hm']],*[names[m] for m in r['inherited']]])
        cards.append('<details class="pokemon" id="pokemon-'+str(r['dex'])+'" data-search="'+esc(search.lower(),quote=True)+'"><summary>'+esc(title)+' <span>'+esc(typ)+'</span></summary><div class="pool">'+''.join(parts)+'</div></details>')
    intro=''.join('<p>'+esc(p)+'</p>' for p in INTRO.split('\n\n'))
    return '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Every Pokémon’s movepool — Purple Iron</title>
<style>body{font:16px/1.6 system-ui,sans-serif;background:#f6f4fa;color:#242033;margin:0}main{max-width:980px;margin:auto;padding:32px 22px}h1{line-height:1.2}a{color:#6236a0}header{margin-bottom:28px}nav{position:sticky;top:0;background:#f6f4faf5;padding:14px 0;display:flex;gap:10px;flex-wrap:wrap;z-index:1}input{flex:1;min-width:220px}input,button{font:inherit;padding:9px 12px;border:1px solid #bdb1ce;border-radius:7px}button{cursor:pointer;background:white}details{background:white;border:1px solid #ded6e8;border-radius:9px;margin:10px 0}summary{padding:14px 18px;font-weight:700;cursor:pointer}summary span{float:right;font-size:.88em;font-weight:400;color:#655971}.pool{padding:0 20px 20px}table{border-collapse:collapse;width:100%;max-width:480px}th,td{text-align:left;padding:5px 12px;border-bottom:1px solid #eee8f3}h3{font-size:1em;margin-bottom:6px}.muted{color:#655971}details[hidden]{display:none}@media print{body{background:white;font-size:10pt}main{padding:0}nav,.links{display:none}details{break-inside:avoid;border:0;border-top:1px solid #aaa}summary{padding-left:0}.pool{padding-left:0}}</style>
<main><header><h1>Every Pokémon’s movepool</h1><p class="muted">Purple Iron · '''+esc(revision)+''' · 10 November 2026</p><p class="links"><a href="ALL-POKEMON-MOVEPOOLS.md">Markdown document</a> · <a href="ALL-POKEMON-MOVEPOOLS.csv">CSV spreadsheet</a></p>'''+intro+'''</header><nav><input id="search" type="search" aria-label="Search Pokémon, move or type" placeholder="Search Pokémon, move or type…"><button id="expand">Expand results</button><button id="collapse">Collapse results</button><button onclick="window.print()">Print / Save PDF</button><span id="count" role="status">183 Pokémon</span></nav>'''+''.join(cards)+'''<p id="empty" hidden>No matching Pokémon.</p></main><script>
const cards=[...document.querySelectorAll('.pokemon')],search=document.querySelector('#search');
search.addEventListener('input',()=>{const terms=search.value.toLowerCase().trim().split(/\\s+/).filter(Boolean);let count=0;for(const card of cards){card.hidden=!terms.every(t=>card.dataset.search.includes(t));if(!card.hidden){count++;card.open=terms.length>0;}}document.querySelector('#count').textContent=count+' Pokémon';document.querySelector('#empty').hidden=count>0;});
document.querySelector('#expand').onclick=()=>cards.filter(c=>!c.hidden).forEach(c=>c.open=true);
document.querySelector('#collapse').onclick=()=>cards.forEach(c=>c.open=false);
let previous=[];window.addEventListener('beforeprint',()=>{previous=cards.map(c=>c.open);cards.filter(c=>!c.hidden).forEach(c=>c.open=true);});window.addEventListener('afterprint',()=>cards.forEach((c,i)=>c.open=previous[i]));
</script></html>'''

if __name__=='__main__':
    red,names=load('pokered');blue,blue_names=load('pokeblue');assert red==blue and names==blue_names,'version-specific learnsets need separate columns'
    # Explicitly verify the inheritance case that motivated separate source lists.
    charm=next(k for k,v in names.items() if v=='Charm')
    assert (40,charm) in red[132]['learn']
    for dex in (134,135,136):assert charm in red[dex-1]['inherited'] and not any(m==charm for _,m in red[dex-1]['learn'])
    revision=subprocess.check_output(['git','rev-parse','--short','HEAD'],cwd=ROOT,text=True).strip()
    for suffix,content in [('md',markdown(red,names,revision)),('csv',spreadsheet(red,names)),('html',webpage(red,names,revision))]:
        path=ROOT/'docs'/('ALL-POKEMON-MOVEPOOLS.'+suffix);path.write_text(content,encoding='utf-8-sig' if suffix=='csv' else 'utf-8');print(path.relative_to(ROOT),path.stat().st_size,'bytes')
    print(f'Verified identical Red/Blue tables: {len(red)} species, {sum(len(r["learn"]) for r in red)} level-up entries, all 68 machine slots, and pre-evolution move sources.')
