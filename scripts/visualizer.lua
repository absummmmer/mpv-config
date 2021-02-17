-- various audio visualization

local opts = {
    mode = "force",
    -- off              disable visualization
    -- noalbumart       enable visualization when no albumart and no video
    -- novideo          enable visualization when no video
    -- force            always enable visualization

    name = "off",
    -- off
    -- showcqt
    -- avectorscope
    -- showspectrum
    -- showcqtbar
    -- showwaves

    quality = "low+",
    -- verylow
    -- low
    -- medium
    -- high
    -- veryhigh

    height = 10,
    -- [4 .. 12]

    force_reload = true,
    rmp = false,
}

local video_sync = mp.get_property("video-sync")
local is_vis = true

if not (mp.get_property("options/lavfi-complex", "") == "") then
    return
end

local audio_id = "1"
local video_id = "1"

local visualizer_name_list = {
    "off",
    "showcqtbar",
    "showcqt",
    "avectorscope",
    "showspatial",
    -- "aphasemeter",
    "ahistogram",
    "showspectrum",
    "showspectrums",
    "abitscope",
    "showfreqs",
    "showwaves",
    -- "stereodiff",
    "showenvelope",
    -- "ebur128",
}

local axis_0 = "image/png;base64," ..
"iVBORw0KGgoAAAANSUhEUgAAB4AAAAAgCAQAAABZEK0tAAAACXBIWXMAAA7EAAAOxAGVKw4bAAASO0lEQVR42u2de2wU1xXGV/If" ..
"SJEqVUJCQrIUISFFiiqhSFWkKFKFokpB1TqxHROT8ApueDgEE9u4MW4TSqFA3TSUQmkSChRwII6BkAQCDSYlBtc1hiSA4/CyMcYG" ..
"tsZvY3t3vXu719vVPjxzz71zd+wBvnOkdvHZ78w5v7mZmbt7Z9blgsFgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaD" ..
"wWCw+9HYBFbKboe8lE1AHHHEEUccccQRRxxxxBFHHPEHNe4KBSJWijjiiCOOOOKII4444ogjjjjiD1icwWAwGAwGg8FgMBgM9hAY" ..
"JsAwGAwGg8FgMBgMBnsozOVyR7zuQOSPdQeif0UcccQRRxxxxBFHHHHEEUcc8QciHn05KaPuwGDHYEfdgUkZRgkQRxxxxBFHHHHE" ..
"EUccccQRR/w+jhu9FQ6Hw+FwOBwOh8Ph8AfOx3Zz07LTXpmYzl89McuJOJ6e/czcCWkP7u4Gf/AHf/AHf/AHf/AHf/AHf/B/iPm7" ..
"3D99qaW2u7n7RqI/8lz4LWbxw1tVNjQh7dgH/Z6RJdjBzmuXKxl7b42sdvqctrORCjqvTc1S3elx9V9vOXNy1+gcP3r+5K6Bu7y8" ..
"YW/jqZO7PPU5S+Tyx/Fp9lysO/CLV1TqA3/wB3/wB3/wB3/wB3/wB3/wB/8x4e9yL37N+PlYP3o+/BazePVe+c089XL7D4n6qjJZ" ..
"dUlhrO7TLWo7wKj+gbvxkGbMv3sl8T3Ht8vlL8hLVPr6dq7Xqw/8wR/8wR/8wR/8wR/8wR/8wR/8k86f/89bK26eYazjSsXGsJ8u" ..
"i90Bo+MVG7ua1HZAY1VoZj9Utacof8b8DSU15cGAmn5tcfnG/zaE2+tqUtsB8fXv33T6w8EOxpprYt9xs46xgK9qT0Hes/M2rbr1" ..
"3cgA2SOfP+hnrLacZ68t72sNiYNvrbBWH/iDP/iDP/iDP/iDP/iDP/iDP/jbxD/8f3UVjF2v5q8ef9HlXpQbyjAcuxY7Gp8y8uV1" ..
"878ZO7lLtsDNv+Ul/e5X0b9cqlT9JGFypq+XscZTHM3bRaq7IFo/9z+/zZivPxrdsY7Xt35l5N8paV3XGavcLp8/4GMs0t+UrFvf" ..
"8mESWcKgVh/4gz/4gz/4gz/4gz/4gz/4gz/428Q/vsC1xQFf9b5JGXcvf3/UqIE1bw57az5yuff/uadleZ5sefzzh8ZTsX+ZPmfv" ..
"O5MzVRCWv8tXhz8xi6O5+pXeDqjaw1hvazTaFNqtjV/Hvn/Xho4ruUut7QCXO/vV4DBja95Ur0+Ff+Fy8Ad/8Ad/8Ad/8Ad/8Ad/" ..
"8Ad/8FfgHy2wt7Wugs+d284aNxCJ36xTbb+7mbGj76uq4p2vYb9U6XIf3sq/LH/qZfUdwOuvq/juM89F/nnD3ndi6gvt1C+06ovf" ..
"AaGMN9Q6Bn/wB3/wB3/wB3/wB3/wB3/wB3/b+UcLjFjbOeMGRPFHnpu7yBzKPQ9jkduSH39xweKcJTlLFiz+Sbas3uVe9jrf8soC" ..
"rh8eZOzETpXtx9cfvgm7IOb76/6Y+sw8Je3Jl+R3AF/TfrpMXq/LX5yf5k/VR/FX6c8K/4npOUvi61XjT+l1+Yvz0/yp+ij+Kv1Z" ..
"4f/oC4tyfz7POn9Kr8tfnJ/mT9VH8Vfpz9rxR+0EMPr4Q5+g9I4/Ipc5/oidPv7I9wf+9yf/1MxXc/kCQav8Rfpk8DfPL8dfVJ8M" ..
"f9n+MP7vv/HPr29/Nts6f0qfjOt/8/xy1/+i+mSu/2X7szb+017JWWK+qJYe/2K9/vgX5ZcZ/+L66PEv35/Djj/RAgfaG6u6Gs0/" ..
"gTCPry4aaOdtNf/70ReMNtJ/i7GyUv6qII/ffv1/Cxbly+ld7otH+Kr469Xcvd2M9d+OXSFP60fqv8vVzdWe+oCXsYA3+hV5/23G" ..
"PvyjGaKfZB/a0nTK211/VH4H3DkfGiQ75PU6/On8Yv4y9Yn4S/dnkX9KWs1HXMEXUZj9epmIv4xehz+dX8xfpj4Rf+n+LPJPzfz+" ..
"GOfLWOfVuYvU+cvodfjT+cX8ZeoT8ZfuzyL/sJcU+geHB+ctVucvo9c7/lP5qeM/XZ/4+C/Zn0X+0+cEfGEf9n77qTp/Gb0Ofzq/" ..
"mL9MfSL+0v1pjP8JabUf8wsvFvzkL1bGP6XXHf/i/PT4p+qjxr9Ufxb5tzdE9i/3jBxV/jJ6Hf50fjF/mfpE/KX7szz+95R6e3jB" ..
"d86b/cCLePzTer3xT+Wnxj9dn3j8S/Znmf9rr/e08Pz9HmvnX1qvx5/KT/Gn6xPzl+xP6/pHbQI8+vpHYgLM12i/t4axugMu94aS" ..
"tm8W5cY3wON/X8fYuYOJF6D3PN7ek7svf8VYTbnRRtrOMla1m796Zm74t564+e+FPwWg9VOz/AOJj7revEp++4lr0J98qb2BsfYf" ..
"Iv/mzzerrTBDdO4gX/3OmPwEeELaUGeowt/K63X40/nF/Gm9mL9Kf1b4f7mNsdvnj29vrmbBq1+r85fR6/Cn84v503oxf5X+rPCv" ..
"2MhYS+2xbRePDA92XlPnL6PX4U/nF/On9WL+Kv1Z4R8m2nmNb9Xst/FE/GX0Ovzp/GL+tF7MX6U/K/yfmcsfqXG58nLlD8e3rlbn" ..
"L6PX4U/nF/On9WL+Kv1ZG/+pmfwpop3Xaj769tDqIvXxT+v1xj+Vnxr/lJ4a//L9WeHf3jDQwffu5cq+NsaM17mI+MvodfjT+cX8" ..
"ab2Yv0p/Vvgvez043Nd6uqzhy4DPU69+/JHR6/Cn84v503oxf5X+rPBPSeu+4R+s3ne6zD8w0G5856yIv4xehz+dX8yf1ov5q/Rn" ..
"9fpHbQI8+vpHegLscucuTQnN7fnTvmK/5o7G85alpI2+AA3jaP5PwBt9eHfUa/kK8JsRNFOypmbxXRJ5DDetP7QltLsG+ArysPe2" ..
"hi45z8hvP3EHuNzb1jLm7Y386/SHoX/1zJgfjU9ML3931sLI7nq7aGK6ygT4c75O3v/MXHm9Dn86v5g/rRfzV+tPnX/bue7m8OdN" ..
"jaeGBxO/+aH5y+h1+NP5xfxpvZi/Wn/q/KdmrS0Ovzr/GWPGP4Mu4i+j1+FP5xfzp/Vi/mr9qfPnzu+84ZdXchPgeP4yeh3+dH4x" ..
"f1ov5q/Wnzp/PsGjfjJCxF9Gr8Ofzi/mT+vF/NX6szL++c+CfHPI+MgmM/5pvd74p/JT45/SU+NfpT91/sX5kUl1b2t3szp/Gb0O" ..
"fzq/mD+tF/NX60+d/4kdjIUnQ98eYsx4kbuIv4xehz+dX8yf1ov5q/Wnzn/mLxk7/eFIH+WM7Vinyl9Gr8Ofzi/mT+vF/NX6s3b9" ..
"ozYBHn39Q0yAfzabPxb79vmi/Ih7vo89QEfjK94YfaftuU+CgfC0k4My+hJ8xnz/YGjG31BakprJPzFYnsefJRbJT+mfnce/+G89" ..
"G/ls7cmX6vYzFgwW54eHAr39+P7eWlGx0VPPF0xE4o/N7LvFv9bfUxr+z6cg785Fxm7GXWKJJnjTsgN+xg5uKsovzt/2+4tHWHD0" ..
"CnSRXo8/nT+Rf96yWP6UnuKv2p8q/6deDt/dMTG9+8Y9jyz/aHe0Xo8/nV/Mn9JT/FX7szb+p8/ZvGqwo7NRnT+tT8b4F+WXGf/m" ..
"ernxL9+fOv+nZ/v6Oq9+9Q+zCR7Fn9Lr8qfyU/zFepq/Wn+q/PkEr/1Sc03LmSPvGU8yxPxpvR5/Or+YP6Wn+Kv2p8p/UoZ/sKvx" ..
"6dkbSqbPkT//RunRej3+dH4xf0pP8Vftz9rxn196m91XJ3P8F+mTcfwX5Zc5/pvr5Y7/8v2p8t+6mrHPt05Ie2LWnfP3/qvOn9br" ..
"8afzi/lTeoq/an+q/GctDH8r63Lvfcf4m0oxf1qvx5/OL+ZP6Sn+qv1ZPf6Yu9zxx3QCnLuUPzR6tEVShOLRdeMsGEicmTediszl" ..
"d65nrLTEaDOfbuFFcbm3h/9oMbfIwUKsX1v8f2XI+CdtM+aH73fkFl7wTG0/vv6IBXwlhdH3FC739ob/7usN5w8Gd/9BboI4a+Fo" ..
"fo1f/zhddoKqy5+egIr5i/WJ/J+dF+Vf+7Fkf0ngPymj5Qxjxz6Q4990amJ64mWKmT45/M3zy/E308vyF/anzX/Lav63oU6jB03I" ..
"8Bfpk8FflF+Gv7lejj/Rnyb/H44Hg0X5lduNJ3g0f7Fen784P81fpJfhT/anxf+JWSMLxgYHOxJ/rEGOP6XX5U/lp/iL9TR/if60" ..
"+OcuDV0sXeCXcEG/0ZM9Kf6UXpc/lZ/iL9bT/CX6S8L51+Wu/djq8UesT8751zy/3PnXTC97/hX2p8mf32Tm7Q0O+/tXvGGFv1iv" ..
"z1+cn+Yv0svwJ/vT4p+S1tfq69+/6eRufpc9fxKyGn9Kr8ufyk/xF+tp/hL9JeX4Y+ayxx/TCfC07PAtzGY7ID7e70m8zb/pdOwE" ..
"9I+/Nt5QacmdC1EQnVc/+lOkRLF+1kK+tG3k8rKLD+/JmXevhHfJ8ODx7TLbT+wvGLznaTr12uuJlxEXDocfZcOt7WxkWSM9wZuW" ..
"3R3NH/T3tzfsKVWZoOryl5kAi/iL9Yn8J2Uk8lftzwr/adn8AfDG9wmM5l9WOvo9Ir0+f1F+Gf7mejn+Kv1Z4f/YzENbQtOMQHP1" ..
"6AOLDH+xXp+/KL8Mf3O9HH+V/lT5/6aQBS8cdrnNJngUf1qvx5/KT/EX62n+qv2pj/+y0tKSiekpafVfMBb74C7Z8U/pdce/OD89" ..
"/kV6mfGv1p8q/02r+F+aq/f+6e6lYDD26aFy/Gm9Hn8qP8VfrKf5q/Zn7fqHP6rGeIGvzPFfrE/G9Y95frnrHzO97PWPfH+q/FMz" ..
"275hbLAj4AsGyt9V50/r9fhT+Sn+Yj3NX7U/9fFflD/QMfLX0DVWzT718U/pdce/OD89/kV6mfGv1p/V44+Zyx5/TCfAuv7NoeBw" ..
"+AHYfAnygsXm73xs5sqCzauK8uO/xpfX626f8tTMksLNqwryjB6QT00wKdfVJyO/MX/n9GfGf/ZCftdBVZnVvLr6ZOU34++U/kTj" ..
"n/snf9F7Wp+uXje/aPw7oT9j/vyjjb62riZ+kmk7a/yMA5Hr6pOX35i/c/qjxn9BHmOf/dV6fl29bn5q/I93f8b8V7zBHzLHX5UU" ..
"MnZyl2pWXX3y8hvzd05/ovFflK93htHVJyO/aPw7oT9j/l+8z9i2tSlpU7MaqwL+KVmqWXX1yctvzN85/ZmP/ylZ61fmLj25m2/J" ..
"SmZdfXLym49/Z/RHnX9tcf0U+zcxtvEt/up6dcCnfgEy3no5fxAmwPdnf+uKfb1BP/9s76mX/75u7PVOr8/u/qK+Yx1j5p/x2q93" ..
"en329Hf5q86r3PlPvd08o35809U7vT67+5ucGbnX74M1jO3aMNZ6p9dnd39TsoaHum/wVzlLGPvXP8Za7/T67O4v7GcPitZ32K93" ..
"en329dfwZdCfOvIAoyN/Y8xskbF9eqfXZ3d/EV/zZsDXdV30qDl79U6vz+7+bPJknAAG2oe6jm///hhjdfvvPz3lxfkXDtcfZay7" ..
"pf5obYX02vKk6Z1en739PTuP37PQ1VR/tP6o5yJjks92S5re6fXZ3Z/L3VzdXP351oObqvcNdfv6jX/mwU690+uzu7+wn9jZfiny" ..
"sInx0Du9Pvv662rsaancvn9TzT5vz1D3tOyx1ju9Prv7c7n5mb3hn59u6bjCTJcY26l3en1298f9nqf7+njqnV6fff2Vv8t/4urE" ..
"zu8+8/V7e1Izx1rv9Prs7u/xF2srTuy4+q9gYKizcPnY651en9392ezJSLJ+5VAXX4DdenZq1v2oF3vl9uhN1v7+2Id1j43e6fXZ" ..
"29/shfF3RryQM7Z6p9dnd38ud/W+yL0Zva3rV4693un12d0f9x+n8x+zZ+yeZ1LGeOidXp+d/ZVv9PaE9293i9kdtnbqnV6f3f3x" ..
"59u3/Cf84JQv3h8PvdPrs7s/l/uR5/pu6Sxu19U7vT57+6v9OHyG6WuL/tTLWOqdXp+9/WXk8AfMMea5+ItXxkPv9Prs7s9mT9Yp" ..
"IHepTvvjrYfD4Waempm7tDj/+QVWl7fo6p1en939wcfXH3luweKifLMfmbFf7/T67O6Pe/ary/MefWH89E6vz+7+4OPpU7Pyls38" ..
"pfXzi67e6fXZ29/kzOV5OrMLXb3T67O7P1sdBxc4HA6Hw+FwOBwOhz8UDgRwOBwOh8PhcDgcDn8oHAjgcDgcDofD4XA4HP4w+P8A" ..
"QEuXMXpD8/kAAAAASUVORK5CYII="

local axis_1 = "image/png;base64," ..
"iVBORw0KGgoAAAANSUhEUgAAB4AAAAAkCAQAAADCge87AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFF2lUWHRYTUw6Y29tLmFkb2Jl" ..
"LnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4" ..
"bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDUgNzkuMTYzNDk5LCAyMDE4LzA4" ..
"LzEzLTE2OjQwOjIyICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRm" ..
"LXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20v" ..
"eGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRw" ..
"Oi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21t" ..
"LyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0" ..
"b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOSAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTAyLTI0VDE4OjIw" ..
"OjQzKzA4OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wMi0yNFQxODozMToyMyswODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAy" ..
"MC0wMi0yNFQxODozMToyMyswODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjEiIHBob3Rv" ..
"c2hvcDpJQ0NQcm9maWxlPSJEb3QgR2FpbiAxNSUiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTAxYzI2YjMtMmYzMi05ZTRk" ..
"LThmNzMtZTU0ODE0N2U5NWQ3IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjEwMWMyNmIzLTJmMzItOWU0ZC04ZjczLWU1NDgx" ..
"NDdlOTVkNyIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjEwMWMyNmIzLTJmMzItOWU0ZC04ZjczLWU1NDgxNDdl" ..
"OTVkNyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3Rh" ..
"bmNlSUQ9InhtcC5paWQ6MTAxYzI2YjMtMmYzMi05ZTRkLThmNzMtZTU0ODE0N2U5NWQ3IiBzdEV2dDp3aGVuPSIyMDIwLTAyLTI0" ..
"VDE4OjIwOjQzKzA4OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOSAoV2luZG93cykiLz4g" ..
"PC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hw" ..
"YWNrZXQgZW5kPSJyIj8+TEdeKQAAEslJREFUeNrtnX9MVFfaxyfhD5Imm2xiYmJC0piYNGk2MU3eNGmabJrmTWo2QysUi61VK1t/" ..
"UCsWkLfI+7aur666bLeuq69vW1ddlWopYm2r1bdi16Isi2hblVJ/gYigziK/EZiBmfPO4e7sDMO95znnnrlw0e/zJLsjz3yfeZ7P" ..
"Pb1zz8y5ZzyefxlLZsXsTtiLWbLHxBBHHHHEEUccccQRRxxxxBFH/EGIe8KBiBUjjjjiiCOOOOKII4444ogjjvgDFmcwGAwGg8Fg" ..
"MBgMBoM9BIYJMAwGg8FgMBgMBoPBHo4JsMcb8dryyB9ry6N/RRxxxBFHHHHEEUccccQRRxzxByIefTg1rbZ8oH2gvbZ8appZAsQR" ..
"RxxxxBFHHHHEEUccccQRn8Rxs6fC4XA4HA6Hw+FwOBz+wDkQwOFwOBwOh8PhcDgcE2A4HA6Hw+FwOBwOh8MxAbbjMzNTX5symz96" ..
"Yq4bcTw979n5yakP7uEGf/AHf/AHf/AHf/AHf/AHf/B/iPl7vP/2cnNNV1PXzXh/5HnjKVbxI9tVXig59fhHfb6RTbhCHdevVDD2" ..
"wTpZ7TOvtp6LVNBxfUaG6kEfVf+N5rOn9ozN8bMXTu3pv8fLG/Y3nD61x1eXtUwu/yg+Tb5LteW/ek2lPvAHf/AHf/AHf/AHf/AH" ..
"f/AHf/AfF/4e79I3zH8h6WcvGE+xilftl3+Zp15p+yleX1kiqy7Kj9V9vk3tAJjV339vNKRZC+9djX/OiZ1y+fNy4pWB3t0b9eoD" ..
"f/AHf/AHf/AHf/AHf/AHf/AH/4Tz5//zzqpbZxlrv1q22fAzJbEHYGy8bHNno9oBaKgMz+wHK/cV5M5auKmoujQUVNOvLyzd/I96" ..
"o73ORtWvuWPrP7jlzMcD7Yw1Vcc+41YtY8FA5b68nOcWbFlz+4eRAbJPPn9oiLGaUp69prS3hX/K8s4qe/WBP/iDP/iDP/iDP/iD" ..
"P/iDP/iDv0P8jf+rLWPsRhV/9PhLHu+S7HCG4di12NH49JEvr5v+xtipPbIFbv0NL+m//yP6l8sVqp8kTEsP9DDWcJqjebdA9RBE" ..
"6+f+x3cZC/RFo7s28Po2ro78Oym18wZjFTvl8wcDjEX6m55x+3s+TCJLGNTqA3/wB3/wB3/wB3/wB3/wB3/wB3+H+I8ucH1hMFB1" ..
"YGravSs/HjNrYN3bw/7qTzzeg3/sbl6Zo/L5Q8Pp0avK9783LV0FYen7fHX4E3M5mmvf6B2Ayn2M9bREo43hw9rwbezz92xqv5q9" ..
"3N4B8HgzXw8NM7bubfX6VPjnrwR/8Ad/8Ad/8Ad/8Ad/8Ad/8Ad/Bf7RAntaasv43Ln1nHkDkfitWtX2u5oYO/ahqmq08zXslys8" ..
"3iPb+ZflT72ifgB4/bVlP3zhu8Q/b9j/Xkx94YP6lVZ9ow9AOONNtY7BH/zBH/zBH/zBH/zBH/zBH/zB33H+0QIj1nrevAFR/JHn" ..
"5y+xhnLfx1jktuTHX1q0NGtZ1rJFS3+RKav3eFe8yV95dR7XDw8wdnK3yuuPrt+4CTsv5vvrvpj6rDwp9cmX5Q8AX9N+pkRer8tf" ..
"nJ/mT9VH8Vfpzw7/KbOzlo2uV40/pdflL85P86fqo/ir9GeH/6MvLsn+9wX2+VN6Xf7i/DR/qj6Kv0p/9s4/am8AY88/9BuU3vlH" ..
"5DLnH7HT5x/5/sB/cvJPSX89my8QtMtfpE8Ef+v8cvxF9cnwl+0P43/yjX9+ffvLefb5U/pEXP9b55e7/hfVJ3P9L9ufvfGf+lrW" ..
"MutFtfT4F+v1x78ov8z4F9dHj3/5/lx2/okW2N/WUNnZYP0JhHV8bUF/G2+r6W+Pvmj2In23GSsp5o/ycvjt1/+0UEGunN7jvXSU" ..
"r4q/UcXd38VY353YFfK0fqT+e1zdVOWrC/oZC/qjX5H33WHs499bIfpF5uFtjaf9XXXH5A/A3QvhQbJLXq/Dn84v5i9Tn4i/dH82" ..
"+SelVn/CFXwRhdWvl4n4y+h1+NP5xfxl6hPxl+7PJv+U9B+Pc76MdVybv0Sdv4xehz+dX8xfpj4Rf+n+bPI3vCh/aGB4YMFSdf4y" ..
"er3zP5WfOv/T9YnP/5L92eT/zKvBgOHD/u8/V+cvo9fhT+cX85epT8Rfuj+N8Z+cWvMpv/Bioc/+ZGf8U3rd8S/OT49/qj5q/Ev1" ..
"Z5N/W33k+HJPy1LlL6PX4U/nF/OXqU/EX7o/2+N/X7G/mxd894LVD7yIxz+t1xv/VH5q/NP1ice/ZH+2+b/xZnczz9/ns/f+S+v1" ..
"+FP5Kf50fWL+kv1pXf+oTYDHXv9ITID5Gu0P1jFWW+7xbipq/W5J9tg13H/ewNj5Q/EXoPd9/p5Te698w1h1qdmLtJ5jrHIvf/Ts" ..
"fOO3nrgN3Tc+BaD1MzKG+uO3ut66Rv7149egP/lyWz1jbT9F/s33N6sps0J0/hBf/c6Y/AQ4OXWwI1zhb+T1Ovzp/GL+tF7MX6U/" ..
"O/y/3sHYnQsndjZVsdC1b9X5y+h1+NP5xfxpvZi/Sn92+JdtZqy55viOS0eHBzquq/OX0evwp/OL+dN6MX+V/uzwN4h2XOevavXb" ..
"eCL+Mnod/nR+MX9aL+av0p8d/s/O51tqXKm4UvHTie1r1fnL6HX40/nF/Gm9mL9Kf/bGf0o630W043r1J98fXlugPv5pvd74p/JT" ..
"45/SU+Nfvj87/Nvq+9v50b1S0dvKmPk6FxF/Gb0Ofzq/mD+tF/NX6c8O/xVvhoZ7W86U1H8dDPjq1M8/Mnod/nR+MX9aL+av0p8d" ..
"/kmpXTeHBqoOnCkZ6u9vM79zVsRfRq/Dn84v5k/rxfxV+rN7/aM2AR57/SM9AfZ4s5cnhef2fLev2K+5o/GcFUmpYy9ADRxNfw/6" ..
"o5t3R72GrwC/FUEzPWNGBj8kkW24af3hbeHD1c9XkBve0xK+5Dwr//rxB8Dj3bGeMX9P5F9nPg7/q3vWwtglpaXvz10cOVzvFkyZ" ..
"rTIB/pKvkx96dr68Xoc/nV/Mn9aL+av1p86/9XxXk/F5U8Pp4YH4b35o/jJ6Hf50fjF/Wi/mr9afOv8ZGesLjUcXvmDM/GfQRfxl" ..
"9Dr86fxi/rRezF+tP3X+3PmdN/zySm4CPJq/jF6HP51fzJ/Wi/mr9afOn0/wqJ+MEPGX0evwp/OL+dN6MX+1/uyMf/6zIN8dNj+z" ..
"yYx/Wq83/qn81Pin9NT4V+lPnX9hbmRS3dPS1aTOX0avw5/OL+ZP68X81fpT539yF2PGZOj7w4yZL3IX8ZfR6/Cn84v503oxf7X+" ..
"1PnP+TVjZz4e6aOUsV0bVPnL6HX40/nF/Gm9mL9af/auf9QmwGOvf4gJ8C/n8W2x71woyI2478fYE3Q0vuqtsXfanv8sFDSmnRyU" ..
"2ZfgsxYODYRn/PXFRSnp/BODlTl8L7FIfkr/3AL+xX/Luchna0++XHuQsVCoMNcYCvTrj+7vnVVlm311fMFEJP7YnN7b/Gv9fcXG" ..
"fz55OXcvMXZr1CWWaII3MzM4xNihLQW5hbk7fnvpKAuNXYEu0uvxp/PH889ZEcuf0lP8VftT5f/UK8bdHVNmd92875PlH+2O1uvx" ..
"p/OL+VN6ir9qf/bG/zOvbl0z0N7RoM6f1idi/Ivyy4x/a73c+JfvT53/0/MCvR3XvvmL1QSP4k/pdflT+Sn+Yj3NX60/Vf58gtd2" ..
"uam6+ezRD8wnGWL+tF6PP51fzJ/SU/xV+1PlPzVtaKCz4el5m4qeeVX+/TdKj9br8afzi/lTeoq/an/2zv/80tvqvjqZ879In4jz" ..
"vyi/zPnfWi93/pfvT5X/9rWMfbk9OfWJuXcv3P+HOn9ar8efzi/mT+kp/qr9qfKfu9j4Vtbj3f+e+TeVYv60Xo8/nV/Mn9JT/FX7" ..
"s3v+sXa584/lBDh7Od80eqxFUoTj0XXjLBSMn5k3no7M5XdvZKy4yOxlPt/Gi+Jyfzf/0WJukZOFWL++8J/KsPFP2mYtNO535GYs" ..
"eKZef3T9EQsGivKjz8lf6e8x/h7oMfKHQnt/JzdBnLt4LL+Gb38+W3aCqsufnoCK+Yv18fyfWxDlX/OpZH8J4D81rfksY8c/kuPf" ..
"eHrK7PjLFCt9Yvhb55fjb6WX5S/sT5v/trX8b4MdZhtNyPAX6RPBX5Rfhr+1Xo4/0Z8m/59OhEIFuRU7zSd4NH+xXp+/OD/NX6SX" ..
"4U/2p8X/ibkjC8YGBtrjf6xBjj+l1+VP5af4i/U0f4n+tPhnLw9fLF3kl3ChIbOdPSn+lF6XP5Wf4i/W0/wl+kvA+6/HW/Op3fOP" ..
"WJ+Y91/r/HLvv1Z62fdfYX+a/PlNZv6e0PBQ36q37PAX6/X5i/PT/EV6Gf5kf1r8k1J7WwJ9B7ec2svvsuc7Iavxp/S6/Kn8FH+x" ..
"nuYv0V9Czj9WLnv+sZwAz8w0bmG2OgCj432++Nv8G8/ETkB//5/mL1RcdPdiFETHtU/+EClRrJ+7mC9tG7m87OTDe1r6vavGIRke" ..
"OLFT5vXj+wuF7vsaT7/xZvxlxMUjxlY2IzutnYssa6QneDMzu6L5Q0N9bfX7ilUmqLr8ZSbAIv5ifTz/qWnx/FX7s8N/ZibfAN78" ..
"PoGx/EuKxz5HpNfnL8ovw99aL8dfpT87/B+bc3hbeJoRbKoae2KR4S/W6/MX5Zfhb62X46/Snyr//8pnoYtHPF6rCR7Fn9br8afy" ..
"U/zFepq/an/q47+kuLhoyuyk1LqvGIvduEt2/FN63fEvzk+Pf5FeZvyr9afKf8uakQ0uq/b/4d7lUCh291A5/rRejz+Vn+Iv1tP8" ..
"Vfuzd/3Dt6oxX+Arc/4X6xNx/WOdX+76x0ove/0j358q/5T01u8YG2gPBkLB0vfV+dN6Pf5Ufoq/WE/zV+1PffwX5Pa3j/w1fI1V" ..
"fUB9/FN63fEvzk+Pf5FeZvyr9Wf3/GP9/a/c+Ud4D7COf3c4NGxsgM2XIC9aav3Mx+asztu6piB39Nf48nrd16c8Jb0of+uavByz" ..
"DfKpCSbluvpE5Dfn757+rPjPW8zvOqgssZtXV5+o/Fb83dKfaPxz/+xPerv16ep184vGvxv6M+fPP9robe1s5G8yrefM9zgQua4+" ..
"cfnN+bunP2r85+Uw9sX/2M+vq9fNT43/ie7PnP+qt/gmc/xRUT5jp/aoZtXVJy6/OX/39Cca/wW5eu8wuvpE5BeNfzf0Z87/qw8Z" ..
"27E+KXVGRkNlcGh6hmpWXX3i8pvzd09/1uN/esbG1dnLT+3lr2Qns64+Mfmtx787+qPefx1x/RQHtzC2+R3+6EZVMKB+ATLR+vGZ" ..
"4LlhAjw5+9tQGOgJDfHP9p565c8bxl/v9vqc7i/quzYwZv0Zr/N6t9fnTH9Xvum4xp3/1Nuts+rnN1292+tzur9p6ZF7/T5ax9ie" ..
"TeOtd3t9Tvc3PWN4sOsmf5S1jLG//mW89W6vz+n+DD93SLS+w3m92+tzrr/6r0NDKSMbGB39X8asFhk7p3d7fU73F/F1bwcDnTdE" ..
"W805q3d7fU7359oJ8PSM/rbBzhM7fzzOWO3ByaenvDD34pG6Y4x1NdcdqymTXlueML3b63O2v+cW8HsWOhvrjtUd811iTHJvt4Tp" ..
"3V6f0/15vE1VTVVfbj+0perAYFegz/xnHpzUu70+p/sz/OTutsuRzSYmQu/2+pzrr7Ohu7li58Et1Qf83YNdMzPHW+/2+pzuz+Pl" ..
"7+z1//f5tvarzHKJsZN6t9fndH/c7/u6bkyk3u31Oddf6fv8J65O7v7hi0Cfvzslfbz1bq/P6f4ef6mm7OSua38NBQc78leOv97t" ..
"9Tndn+snwB7vxtWDnXwBdsu5GRmTUS/2ip3Rm6yH+mI36x4fvdvrc7a/eYtH3xnxYtb46t1en9P9ebxVByL3ZvS0bFw9/nq31+d0" ..
"f9x/Ppv/mD1j931T0yZC7/b6nOyvdLO/2zi+Xc1Wd9g6qXd7fU73x/e3b/67sXHKVx9OhN7t9Tndn8f7yPO9t3UWt+vq3V6fs/3V" ..
"fGq8w/S2Rn/qZTz1bq/P2f7SsvgGc4z5Lv3qtYnQu70+p/ubBBNgfgrOXq7T/kTr4XC4laekZy8vzH1hkd3lLbp6t9fndH/wifVH" ..
"nl+0tCDX6kdmnNe7vT6n++Oe+frKnEdfnDi92+tzuj/4RPqMjJwVc35t//1FV+/2+pztb1r6yhyd2YWu3u31Od3fJJgAw+FwOBwO" ..
"h8PhcDgcjgkwHA6Hw+FwOBwOh8PhbpoAT02rLR/sGOyoLTe/jwpxxBFHHHHEEUccccQRRxxxxCdxPPqwtjyykY75XpqII4444ogj" ..
"jjjiiCOOOOKIIz6J4wwGg8FgMBgMBoPBYLCHwDABhsFgMBgMBoPBYDDYwzEBjhor/tdfiz0mhjjiiCOOOOKII4444ogjjjjiD0Lc" ..
"w5LDT7kd9mKWjDjiiCOOOOKII4444ogjjjjiD1b8/wGZc32s5tZqKAAAAABJRU5ErkJggg=="

local options = require 'mp.options'
local msg     = require 'mp.msg'

options.read_options(opts)
opts.height = math.min(12, math.max(4, opts.height))
opts.height = math.floor(opts.height)

if opts.name == "off" then
    is_vis = false
end

local function aid_change(name, value)
    if not is_vis then
        audio_id = value
        if audio_id == "no" or audio_id == "auto" then
            audio_id = "1"
        end
    end
end

local function get_visualizer(aid, name, quality)
    local w, h, fps

    if quality == "verylow" then
        w = 640
        fps = 30
    elseif quality == "low" then
        w = 960
        fps = 30
    elseif quality == "low+" then
        w = 1152
        fps = mp.get_property_number("display-fps", 30)
    elseif quality == "low60" then
        w = 960
        fps = 60
    elseif quality == "medium" then
        w = 1280
        fps = 60
    elseif quality == "high" then
        w = 1920
        fps = 60
    elseif quality == "veryhigh" then
        w = 2560
        fps = 60
    else
        msg.log("error", "invalid quality")
        return ""
    end

    h = w * opts.height / 16
    -- h = 2 * math.floor((w * opts.height / 16 / mp.get_property_number("monitorpixelaspect") +.5) / 2)

    if name == "showcqt" then
        is_vis = true
        local count = math.ceil(w * 180 / 1920 / fps)
        local axis_h = math.ceil(w * 32 / 1920)

        return "[aid" .. aid .. "]asplit[ao],afifo,aformat=sample_rates=192000:channel_layouts=stereo," ..
            "firequalizer=gain='1.4884e8*f*f*f/(f*f+424.36)/(f*f+1.4884e8)/sqrt(f*f+25122.25)':" ..
                "scale=linlin:wfunc=tukey:zero_phase=on:fft2=on," ..
            "showcqt=fps=" .. math.floor(fps) .. ":size=" .. w .. "x" .. h .. ":count=" .. count .. ":" ..
                "csp=bt709:bar_h=0:bar_g=2:sono_g=4:bar_v=9:sono_v=13:axisfile=data\\\\:'" .. axis_0 .. "':" ..
                "font='Nimbus Mono L,Courier New,mono|bold':" ..
                "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
                "tc=0.5:attack=0.02:" ..
                "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            "format=yuv420p,split [v0],crop=h=" .. h - axis_h + 1 .. ":y=" .. axis_h .. ",vflip[v1];" ..
            "[v0]crop=h=" .. axis_h .. ":y=0[v2];[v1][v2]vstack[vo]"

    elseif name == "avectorscope" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo,aformat=sample_rates=192000," ..
            "avectorscope=mode=polar:size=" .. w .. "x" .. h .. ":r=" .. fps .. ":" ..
                "swap=0:draw=dot:scale=lin," ..
            "format=rgb0[vo]"

    elseif name == "ahistogram" then
        is_vis = true
        local chs = mp.get_property_number("audio-params/channel-count", 2)
        local vol_h = (16 + 2) * chs - 2
        -- local gramr = h * .1 / (h - vol_h)
        local svs = 3

        return "[aid" .. aid .. "]asplit[ao],afifo,asplit=4[sc][gr][au][av];" ..
            "[sc]ahistogram=size=" .. w .. "x" .. math.floor((h * .9 - vol_h) / 0.8) .. ":r=" .. fps * svs .. ":" ..
                    "scale=log:ascale=log:acount=1:rheight=0.2:dmode=separate:slide=scroll," ..
                "mergeplanes=0x000102:yuv444p,framestep=" .. svs .. ",vflip,split[logbt]," ..
                "crop=h=0.8*ih:y=0[scroll];" ..
                -- "drawbox=0:" .. math.floor((h - vol_h) * (gramr)) .. ":" .. w .. ":1:invert:1," ..
                "[logbt]crop=h=1:y=0.8*ih+1[bt];" ..
            "[gr]ahistogram=size=" .. w .. "x" .. math.ceil(h * .1) - 1 .. ":r=" .. fps .. ":" ..
                    "scale=lin:ascale=log:acount=1:rheight=1:dmode=separate:slide=scroll," ..
                "mergeplanes=0x000102:yuv444p[gram];" ..
            "[av]showvolume=r=" .. fps .. ":w=" .. math.max(80, vol_h) .. ":h=2:b=1:f=0:m=p:o=v:ds=log:t=0:v=0" ..
                (vol_h < 80 and ",scale=h=" .. vol_h or "") .. ",format=yuv444p[vbar];" ..
            "[au]showvolume=r=" .. fps .. ":w=" .. w - (3 * chs - 1) - 2 .. ":h=16:b=2:f=.5:m=p:ds=lin:dm=.5," ..
                "format=yuv444p,pad=w=iw+2[hbar];" ..
            "[hbar][vbar]hstack[bar];[scroll][bar][gram][bt]vstack=4,fps=" .. fps .. "[vo]"

    elseif name == "abitscope" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "abitscope=size=" .. w .. "x" .. h .. ":r=" .. fps .. ",format=rgb0[vo]"

    elseif name == "aphasemeter" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "aphasemeter=size=" .. w .. "x" .. h .. ":r=" .. fps .. "[au],format=rgb0[vo];[au]anullsink"

    elseif name == "showspatial" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "showspatial=size=" .. w .. "x" .. h .. ":win_size=2048[vo]"

    elseif name == "ebur128" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "ebur128=video=1:meter=18:size=" .. w .. "x" .. h .. "[vo][a];[a]anullsink"

    elseif name == "showfreqs" then
        is_vis = true
        local width = w -- math.ceil(w / .9375)
        local ch = mp.get_property_number("audio-params/channel-count", 2)
        local common = "cmode=separate:minamp=1e-6:fscale=lin:overlap=1-1/2:win_func=bharris"
        return "[aid" .. aid .. "]asplit[ao],afifo,asplit=4[au][ac][ax]," ..
            "showfreqs=size=" .. width .. "x" .. h - 16 .. ":" ..
                "mode=line:averaging=0:ascale=log:" .. common .. "," ..
                "framestep=" .. math.max(1, math.floor(
                    (mp.get_property_number("audio-params/samplerate", 44100) / 1024) / fps + .5)) .. "," ..
                "lut=r=val*.1:g=val*.1:b=val*.1[peak];" ..
            "[au]showfreqs=size=" .. width .. "x" .. h - 16 .. ":" ..
                "mode=dot:averaging=1:ascale=log:" .. common .. "," ..
                -- "tmix=4:.125 .25 .5 1:1," ..
                "framestep=" .. math.max(1, math.floor(
                    (mp.get_property_number("audio-params/samplerate", 44100) / 1024) / fps + .5)) .. "[log];" ..
            "[peak][log]overlay=format=rgb[line];" ..
            "[ac]showfreqs=size=" .. width .. "x" .. h - 16 .. ":" ..
                "mode=bar:averaging=1:ascale=cbrt:" .. common .. "," ..
                -- "drawgrid=0:-1:" .. 75 .. ":" .. h - 16 .. ":invert," ..
                "framestep=" .. math.max(1, math.floor(
                    (mp.get_property_number("audio-params/samplerate", 44100) / 1024) / fps + .5)) .. "[cbrt];" ..
            -- "[peak][log][cbrt]mix=3:.1 1 1:1:shortest[freq];" ..
            "[line][cbrt]overlay=format=rgb[freq];" ..
            "[ax]showspectrum=size=" .. math.pow(2, math.ceil(math.log(w) / math.log(2))) .. "x" .. 16 .. ":" ..
                "fps=" .. fps .. ":orientation=horizontal:fscale=lin:legend=1," ..
                "crop=" .. math.pow(2, math.ceil(math.log(w) / math.log(2))) .. ":16:" ..
                    "(in_w-out_w)/2:(in_h-out_h)/2+17,scale=" .. w .. ":16,setsar=1,format=rgb0,[freq]vstack=2:1," ..
            "fps=" .. math.min(fps, (mp.get_property_number("audio-params/samplerate", 44100) / 1024)) .. "," ..
            "format=rgb0[vo]"

    elseif name == "showspectrum" then
        is_vis = true
        local width = math.pow(2, math.ceil(math.log(w) / math.log(2) - 1/3))
        local height = width * opts.height / 16
        local sr = mp.get_property_number("audio-params/samplerate", 44100)
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "showspectrum=size=" .. width .. "x" .. height .. ":fps=" .. fps .. ":" ..
                -- "fscale=log:" ..
                -- "scale=cbrt:" ..
                "overlap=1-" .. (sr > 96000 and "2" or "1") .. "/4:" ..
                "slide=scroll:orientation=horizontal:legend=1:win_func=blackman," ..
            -- "framestep=" .. math.max(1,
            --     math.floor((mp.get_property_number("audio-params/samplerate") / width) / fps * 2 + .5)) .. "," ..
            "crop=" .. width .. ":" .. height .. ":(in_w-out_w)/2:(in_h-out_h)/2+" .. 16 .. "," ..
            "scale=" .. w .. ":" .. h .. ":sws_flags=bilinear[vo]"

    elseif name == "showspectrums" then
        is_vis = true
        local ch = mp.get_property_number("audio-params/channel-count", 2)
        local sr = mp.get_property_number("audio-params/samplerate", 44100)
        local width = math.pow(2, math.ceil(math.log(math.max(256, w / ch)) / math.log(2) - 1/2)) * ch
        local height = width * opts.height / 16
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "showspectrum=size=" .. width .. "x" .. height .. ":" ..
                "fps=" .. ((ch > 6) and math.max(math.min(30, fps), fps / 2) or fps) .. ":" ..
                "mode=separate:scale=log:overlap=1-" .. (sr > 96000 and "2" or "1") .. "/3:" ..
                "slide=scroll:orientation=horizontal:legend=1:win_func=hann," ..
            -- "framestep=" ..
            --     math.max(1, math.floor((mp.get_property_number(
            --         "audio-params/samplerate") / math.max(256, width / ch)) / fps * 3/2 + .5)) .. "," ..
            "crop=" .. width .. ":" .. height .. ":(in_w-out_w)/2:(in_h-out_h)/2+" .. 16 .."," ..
            "scale=" .. w .. ":" .. h .. ":sws_flags=bilinear[vo]"

    elseif name == "showcqtbar" then
        is_vis = true
        local sr = mp.get_property_number("audio-params/samplerate", 44100)
        local ch = mp.get_property_number("audio-params/channel-count", 2)
        local count = math.ceil(w * 180 / 1920 / fps)
        local axis_h = math.ceil(w * 32 / 1920)

        return "[aid" .. aid .. "]asplit[ao],afifo,aformat=" ..
                (sr > 96000 and "sample_rates=96000:" or "") .. "channel_layouts=stereo," ..
            "firequalizer=gain='1.4884e8*f*f*f/(f*f+424.36)/(f*f+1.4884e8)/sqrt(f*f+25122.25)':" ..
                "scale=linlin:wfunc=tukey:zero_phase=on:fft2=on," ..
            "asplit=3[a0][a1][a2];" ..
            -- "[a0]stereotools=slev=0.015625,stereotools=slev=0.015625,asplit [mdl][mdr];" ..
            -- "[a1]stereotools=mlev=0.015625,stereotools=mlev=0.015625," ..
            -- "[a1]channelsplit[side_l][side_r];anullsrc=cl=mono,asplit[nll][nlr];" ..
            -- "[side_l][nll]amerge,channelmap=0|1:stereo[sdl];[side_r][nlr]amerge,channelmap=1|0:stereo[sdr];" ..
            -- "[mdl][sdl] amix," ..
            "[a0]pan=stereo|c0=c0," ..--" asplit [snl]," ..
            "showcqt=fps=" .. math.floor(fps) .. ":size=" .. w .. "x" .. (h + axis_h)/2 .. ":" .. "count=5:" ..
                "csp=bt709:bar_g=2:sono_g=4:bar_v=13:sono_v=17:sono_h=0:axisfile=data\\\\:'" .. axis_1 .. "':" ..
                "axis_h=" .. axis_h .. ":font='Nimbus Mono L,Courier New,mono|bold':" ..
                "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
                "tc=0.33:attack=0.033:" ..
                "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            -- "format=rgb0," ..
            "crop=h=" .. (h - axis_h)/2 .. ":y=0[v0];" ..
            -- "[snl]showcqt=fps=" .. fps .. ":size=" .. w .. "x" .. (h + axis_h)/2 .. ":" ..
            --     "count=" .. count .. ":csp=bt709: cscheme=1|0.25|0|0|0.25|1:" ..
            --     "bar_g=2:sono_g=4:bar_v=9:sono_v=1:bar_h=0:axisfile=data\\\\:'" .. axis_1 .. "':" ..
            --     "axis_h=" .. axis_h .. ":font='Nimbus Mono L,Courier New,mono|bold':" ..
            --     "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
            --     "tc=0.33:attack=0.033:" ..
            --     "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            -- "format=rgb0,crop=h=" .. (h - axis_h)/2 .. ":y=" .. axis_h .. ",vflip[v01];[v00][v01]blend=all_mode=screen[v0];" ..
            -- "[mdr][sdr]amix," ..
            "[a1]pan=stereo|c1=c1," ..--" asplit [snr]," ..
            "showcqt=fps=" .. math.floor(fps) .. ":size=" .. w .. "x" .. (h + axis_h)/2 .. ":" .. "count=5:" ..
                "csp=bt709:bar_g=2:sono_g=4:bar_v=13:sono_v=17:sono_h=0:axisfile=data\\\\:'" .. axis_1 .. "':" ..
                "axis_h=" .. axis_h .. ":font='Nimbus Mono L,Courier New,mono|bold':" ..
                "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
                "tc=0.33:attack=0.033:" ..
                "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            -- "format=rgb0," ..
            "crop=h=" .. (h - axis_h)/2 .. ":y=0,vflip[v1];" ..
            -- "[snr]showcqt="fps=" .. fps .. ":size=" .. w .. "x" .. (h + axis_h)/2 .. ":" ..
            --     "count=" .. count .. ":csp=bt709: cscheme=1|0.25|0|0|0.25|1:" ..
            --     "bar_g=2:sono_g=4:bar_v=9:sono_v=1:bar_h=0:axisfile=data\\\\:'" .. axis_1 .. "':" ..
            --     "axis_h=" .. axis_h .. ":font='Nimbus Mono L,Courier New,mono|bold':" ..
            --     "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
            --     "tc=0.33:"attack=0.033:" ..
            --     "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            -- "format=rgb0,crop=h=" .. (h - axis_h)/2 .. ":y=" .. axis_h .. "[v11];[v10][v11]blend=all_mode=screen[v1];" ..
            "[a2]showcqt=fps=" .. math.floor(fps) .. ":size=" .. w .. "x" .. (h + axis_h)/2 .. ":" .. "count=5:" ..
                "csp=bt709:bar_g=2:sono_g=4:bar_v=11:sono_v=17:sono_h=0:axisfile=data\\\\:'" .. axis_1 .. "':" ..
                "axis_h=" .. axis_h .. ":font='Nimbus Mono L,Courier New,mono|bold':" ..
                "fontcolor='st(0,(midi(f)-53.5)/12);st(1,0.5-0.5*cos(PI*ld(0)));r(1-ld(1))+b(ld(1))':" ..
                "tc=0.33:attack=0.033:" ..
                "tlength='st(0,0.17);384*tc/(384/ld(0)+tc*f/(1-ld(0)))+384*tc/(tc*f/ld(0)+384/(1-ld(0)))'," ..
            -- "format=rgb0," ..
            "crop=y=" .. (h - axis_h)/2 .. ":h=" .. axis_h .. "[v2];[v0][v2][v1]vstack=3" .. (ch == 1 and
            ",format=gray" or "") .. "[vo]"

    elseif name == "showwaves" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],afifo," ..
            "showwaves=size=" .. w .. "x" .. h .. ":" ..
                "n=1:split_channels=1:mode=p2p," ..
            -- "tmix=5:.0625 .125 .25 .5 1:1," ..
            "format=rgb0[vo]"

    elseif name == "stereodiff" then
        is_vis = true
        return "[aid" .. aid .. "]asplit[ao],aformat=channel_layouts=stereo," ..
            "afifo,asplit[s],channelsplit[l][r];" ..
            "[l]showwaves=size=" .. w .. "x" .. h .. ":n=1:mode=line[left];" ..
            "[s]showwaves=size=" .. w .. "x" .. h .. ":n=1:mode=p2p[stereo];" ..
            "[r]showwaves=size=" .. w .. "x" .. h .. ":n=1:mode=line[right];" ..
            "[left][right]blend=all_mode=xor,format=gray[diff];" ..
            "[stereo]format=gray,[diff]blend=all_mode=addition,lut=c0=255*val[vo]"

    elseif name == "showenvelope" then
        is_vis = true
        local range = mp.get_property_number("demuxer-readahead-secs", 1) / 8 -- make floor() work best, MUST <= 1, mp.get_property_number("demuxer-readahead-secs")/2
        local n = math.floor(192e3--[[mp.get_property_number("demuxer-readahead-secs") * mp.get_property_number("audio-params/samplerate")]] / w * range)
        local amp = mp.get_property_number("audio-params/channel-count", 2)
        local bkwd = (mp.get_property("play-dir") == "backward")
        return "[aid" .. aid .. "]asplit[ao],aformat=sample_rates=192000," ..
            "asetpts=PTS" .. (bkwd and "+" or "+") .. range / 2 .. ",afifo," ..
            "showwaves=size=" .. w --[[/ n]] .. "x" .. h .. ":n=" .. n .. ":mode=p2p:draw=scale," ..
                -- "scale=" .. w .. ":" .. h .. ":force_original_aspect_ratio=disable," ..
                -- "setsar=1," ..
            "fps=" .. 1 / range .. ",split[lt],setpts=PTS" .. (bkwd and "+" or "-") .. "TB[rt];" ..
            "[" .. (bkwd and "r" or "l") .. "t][" .. (bkwd and "l" or "r") .. "t]hstack," ..
            "fps=" .. math.ceil(2 * fps * (1 - 1e-3) * range) / range .. "," ..
            -- "minterpolate=" ..
            --     "fps=" .. fps .. ":" ..
            --     "mi_mode=dup," ..
            "crop=w=" .. w .. ":x=mod(t\\," .. range .. ")/" .. range .. "*iw/2" .. (bkwd and ",hflip," or ",") ..
            -- "drawbox=" .. w / 2 .. ":0:1:0:DimGray@" .. 0.5 / n .. ":1,format=rgb0," ..
            "lut=r=val*" .. math.sqrt(3)*n ..":g=val*" .. math.sqrt(3)*n ..":b=val*" .. math.sqrt(3)*n .. "," ..
            "format=rgb0,framestep=2[vo]"

    elseif name == "off" then
        is_vis = false
        return "[aid" .. aid .. "] afifo [ao]"
    end

    msg.log("error", "invalid visualizer name")
    return ""
end

local function select_visualizer(atrack, vtrack, albumart, aid)
    if opts.mode == "off" then
        return ""
    elseif opts.mode == "force" then
        if atrack == 0 then
            return ""
        end
        return get_visualizer(aid, opts.name, opts.quality)
    elseif opts.mode == "noalbumart" then
        if albumart == 0 and vtrack == 0 then
            return get_visualizer(aid, opts.name, opts.quality)
        end
        return ""
    elseif opts.mode == "novideo" then
        if vtrack == 0 then
            return get_visualizer(aid, opts.name, opts.quality)
        end
        return ""
    end

    msg.log("error", "invalid mode")
    return ""
end

local function visualizer_hook()
    local count = mp.get_property_number("track-list/count", -1)
    local atrack = 0
    local vtrack = 0
    local albumart = 0
    if count <= 0 then
        return
    end
    for tr = 0,count-1 do
        if mp.get_property("track-list/" .. tr .. "/type") == "audio" then
            atrack = atrack + 1
        else
            if mp.get_property("track-list/" .. tr .. "/type") == "video" then
                if mp.get_property("track-list/" .. tr .. "/albumart") == "yes" then
                    albumart = albumart + 1
                else
                    vtrack = vtrack + 1
                end
            end
        end
    end

    local aid = mp.get_property("aid", "")
    if aid == "no" or aid == "auto" then aid = audio_id end
    local visual = select_visualizer(atrack, vtrack, albumart, aid)
    if is_vis then
        --[[ if mp.get_property_native("osd-level") == 2 then
            mp.set_property_native("osd-level", 3)
            msg.debug("vis on, osd-level 3")
        end ]]
        -- local sync = video_sync
        mp.set_property("video-sync", "audio")
        -- mp.add_timeout(0.033, function()
        --     video_sync = sync
        -- end)
    else
        --[[ if mp.get_property("vid") == "no" then
            mp.set_property_native("osd-level", 2)
            msg.debug("vis off, osd-level 2")
        end ]]
        mp.set_property("video-sync", video_sync)
    end
    mp.set_property("options/lavfi-complex", visual)
    -- mp.command("seek 0 relative+keyframes")
end

mp.add_hook("on_preloaded", 50, visualizer_hook)

local function cycle(reverse)
    local i, index = 1
    for i = 1, #visualizer_name_list do
        if (visualizer_name_list[i] == opts.name) then
            if reverse then
                index = i + 1
                if index > #visualizer_name_list then
                    index = 1
                end
            else
                index = i - 1
                if index < 1 then
                    index = #visualizer_name_list
                end
            end
            break
        end
    end
    opts.name = visualizer_name_list[index]
    visualizer_hook()
end

local function clear_visualizer()
    if get_visualizer(audio_id, opts.name, opts.quality)
        == get_visualizer(audio_id, "off", opts.quality) then return
    end
    opts.name = visualizer_name_list[1]
    visualizer_hook()
end

local function cycle_visualizer() cycle(true) end
local function cycler_visualizer() cycle(false) end

mp.observe_property("aid", "string", aid_change)
-- mp.observe_property("vid", "string", function(name, value)
--     video_id = value
--     if value ~= "no" then
--         is_vis = false
--         opts.name = "off"
--     end
-- end)
mp.observe_property("play-dir", "string", visualizer_hook)
-- mp.observe_property("lavfi-complex", "string", function(name, value)
--     if value == "" then
--         mp.commandv("seek", "0", "exact")
--         -- mp.commandv("seek", "-" .. mp.get_property("demuxer-readahead-secs"), "exact")
--     end
-- end)
-- mp.observe_property("video-sync", "string", function(name, value)
--     video_sync = value
-- end)

mp.add_key_binding(nil, "clear-visualizer", clear_visualizer)
mp.add_key_binding(nil, "cycle-visualizer", cycle_visualizer)
mp.add_key_binding(nil, "cycle-reverse-visualizer", cycler_visualizer)

mp.add_key_binding(nil, "cplayer-show-window", function()
    if not mp.get_property_bool("vo-configured") then
        mp.set_property("force-window", "yes")
        --[[ if not mp.get_property_bool("idle-active") and opts.force_reload then
            msg.info("Reloading ...")
            mp.commandv("script-binding", "reload/reload_resume")
        end ]]
    else mp.set_property("force-window", "no") end
end)

-- if opts.rmp then
--     mp.commandv('script-binding', 'cplayer-show-window')
-- end
