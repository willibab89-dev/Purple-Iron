#!/usr/bin/env python3
"""Verify the submitted species art is preserved and converted correctly."""
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
NAMES=('garmic','fangrir','hoppip','skiploom','jumpluff','tyker','straigar',
       'umbreon','phanpy','donphan','mareep','flaaffy','ampharos','embear','ursear','volkuma')
PALETTE=[(255,255,255),(170,170,170),(85,85,85),(0,0,0)]

def validate():
    for name in NAMES:
        for suffix in ('','_b'):
            source=Image.open(ROOT/'pic/new_species/submitted'/f'{name}{suffix}.png').convert('RGB')
            output=Image.open(ROOT/'pic/new_species'/f'{name}{suffix}.png')
            assert output.mode=='P' and output.size==(56,56), (name,suffix)
            palette=output.getpalette();assert [tuple(palette[i:i+3]) for i in range(0,12,3)]==PALETTE
            dx=(56-source.width)//2;dy=56-source.height
            for y in range(56):
                for x in range(56):
                    if dx<=x<dx+source.width and dy<=y<dy+source.height:
                        r,g,b=source.getpixel((x-dx,y-dy));assert r==g==b
                        expected=0 if r>220 else 1 if r>130 else 2 if r>40 else 3
                    else: expected=0
                    assert output.getpixel((x,y))==expected,(name,suffix,x,y)
    print('All 32 supplied front/back sprites: source and four-shade conversion verified')

if __name__=='__main__':validate()
