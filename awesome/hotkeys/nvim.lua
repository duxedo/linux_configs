---------------------------------------------------------------------------
--- NVIM hotkeys for awful.hotkeys_widget
--
-- @author Yauheni Kirylau &lt;yawghen@gmail.com&gt;
-- @copyright 2014-2015 Yauheni Kirylau
-- @submodule awful.hotkeys_popup
---------------------------------------------------------------------------

local hotkeys_popup = require("awful.hotkeys_popup.widget")

local nvim_keys = {

    ["NVIM: motion"] = {{
        modifiers = {},
        keys = {
            ['`']="goto mark",
            ['0']='"hard" BOL',
            ['-']="prev line",
            w="next word",
            e="end word",
            ['[']=". misc",
            [']']=". misc",
            ["'"]=". goto mk. BOL",
            b="prev word",
            ["|"]='BOL/goto col',
            ["$"]='EOL',
            ["%"]='goto matching bracket',
            ["^"]='"soft" BOL',
            ["("]='sentence begin',
            [")"]='sentence end',
            ["_"]='"soft" BOL down',
            ["+"]='next line',
            W='next WORD',
            E='end WORD',
            ['{']="paragraph begin",
            ['}']="paragraph end",
            G='EOF/goto line',
            H='move cursor to screen top',
            M='move cursor to screen middle',
            L='move cursor to screen bottom',
            B='prev WORD',
        }
    }, {
        modifiers = {"Ctrl"},
        keys = {
            u="half page up",
            d="half page down",
            b="page up",
            f="page down",
            o="prev mark",
        }
    }},

    ["NVIM: operator"] = {{
        modifiers = {},
        keys = {
            ['=']="auto format",
            y="yank",
            d="delete",
            c="change",
            ["!"]='external filter',
            ['&lt;']='unindent',
            ['&gt;']='indent',
        }
    }},

    ["NVIM: command"] = {{
        modifiers = {},
        keys = {
            ['~']="toggle case",
            q=". record macro",
            r=". replace char",
            u="undo",
            p="paste after",
            gg="go to the top of file",
            gf="open file under cursor",
            x="delete char",
            v="visual mode",
            m=". set mark",
            ['.']="repeat command",
            ["@"]='. play macro',
            ["&amp;"]='repeat :s',
            Q='ex mode',
            Y='yank line',
            U='undo line',
            P='paste before cursor',
            D='delete to EOL',
            J='join lines',
            K='help',
            [':']='ex cmd line',
            ['"']='. register spec',
            ZZ='quit and save',
            ZQ='quit discarding changes',
            X='back-delete',
            V='visual lines selection',
        }
    }, {
        modifiers = {"Ctrl"},
        keys = {
            w=". window operations",
            r="redo",
            ["["]="normal mode",
            a="increase number",
            x="decrease number",
            g="file/cursor info",
            z="suspend",
            c="cancel/normal mode",
            v="visual block selection",
        }
    }},

    ["NVIM: command (insert)"] = {{
        modifiers = {},
        keys = {
            i="insert mode",
            o="open below",
            a="append",
            s="subst char",
            R='replace mode',
            I='insert at BOL',
            O='open above',
            A='append at EOL',
            S='subst line',
            C='change to EOL',
        }
    }},

    ["NVIM: find"] = {{
        modifiers = {},
        keys = {
            [';']="repeat t/T/f/F",
            [',']="reverse t/T/f/F",
            ['/']=". find",
            ['?']='. reverse find',
            n="next search match",
            N='prev search match',
            f=". find char",
            F='. reverse find char',
            t=". 'till char",
            T=". reverse 'till char",
            ["*"]='find word under cursor',
            ["#"]='reverse find under cursor',
        }
    }},

    ["NVIM: scroll"] = {{
        modifiers = {},
        keys = {
            zt="scroll cursor to the top",
            zz="scroll cursor to the center",
            zb="scroll cursor to the bottom",
        }
    },{
        modifiers = {"Ctrl"},
        keys = {
            e="scroll line up",
            y="scroll line down",
        }
    }},

    ["NVIM: fold"] = {{
        modifiers = {},
        keys = {
            za="toggle",
            zc="close",
            zo="open",
            zA="toggle recursive",
            zC="close recursive",
            zO="open recursive",
            zm="close all one level",
            zr="open all one level",
            zM="close all",
            zR="open all",
        }
    }},

    ["NVIM: diff"] = {{
        modifiers = {},
        keys = {
            ["do"]="diff obtain",
            ["dp"]="diff put",
            ["]c"]="jump next",
            ["[c"]="jump previous",
        }
    }},
}


return function(widget)
    widget:add_hotkeys(nvim_keys)
    for group_name, _ in pairs(nvim_keys) do
        widget:add_group_rules(group_name, { rule_any= { name = {"NVIM"} } })
    end
end


