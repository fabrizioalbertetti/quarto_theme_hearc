-- Transmet les paramètres communs du cours (clé `course` de _quarto.yml)
-- au thème HE-Arc :
--   beamer  : macros LaTeX dans le préambule (lues par beamerthemehearc-ing.sty) ;
--   revealjs : ligne « cours · classe » de la page de titre et pied de page,
--              plus quelques équivalences avec Beamer (blocs, allowframebreaks).

local function to_latex(value)
  if value == nil then
    return ""
  end
  local inlines
  if pandoc.utils.type(value) == "Inlines" then
    inlines = value
  else
    inlines = pandoc.Inlines(pandoc.utils.stringify(value))
  end
  local tex = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "latex")
  return (tex:gsub("%s+$", ""))
end

local function to_inlines(value)
  if value == nil then
    return pandoc.Inlines({})
  end
  if pandoc.utils.type(value) == "Inlines" then
    return value
  end
  return pandoc.Inlines(pandoc.utils.stringify(value))
end

-- « Nom du cours · Classe », sans séparateur orphelin si un champ manque
local function course_line(name, class)
  local line = pandoc.Inlines({})
  line:extend(name)
  if #name > 0 and #class > 0 then
    line:insert(pandoc.Space())
    line:insert(pandoc.Span("•", { class = "hearc-dot" }))
    line:insert(pandoc.Space())
  end
  line:extend(class)
  return line
end

local function beamer_meta(meta)
  local course = meta.course or {}
  local name = to_latex(course.name)
  local short = to_latex(course.short)
  if short == "" then
    short = name
  end

  quarto.doc.include_text("in-header", table.concat({
    "\\makeatletter",
    "\\def\\hearc@coursename{" .. name .. "}",
    "\\def\\hearc@courseshort{" .. short .. "}",
    "\\def\\hearc@courseclass{" .. to_latex(course.class) .. "}",
    "\\def\\hearc@footer{" .. to_latex(course.footer) .. "}",
    "\\makeatother",
  }, "\n"))
end

-- Pied de page revealjs, calculé par revealjs_meta
local footer = nil

local function revealjs_meta(meta)
  local course = meta.course or {}
  local name = to_inlines(course.name)
  local short = to_inlines(course.short)
  if #short == 0 then
    short = name
  end
  local class = to_inlines(course.class)

  meta["hearc-courseline"] = course_line(name, class)

  footer = pandoc.Inlines({})
  local left = to_inlines(course.footer)
  if #left > 0 then
    footer:insert(pandoc.Span(left, { class = "hearc-footer-left" }))
  end
  footer:extend(course_line(short, class))
end

local function Meta(meta)
  if quarto.doc.is_format("beamer") then
    beamer_meta(meta)
  elseif quarto.doc.is_format("revealjs") then
    revealjs_meta(meta)
  end
  return meta
end

-- revealjs : Quarto insère un `::: {.footer .footer-default}` avant les
-- filtres, vide si `footer:` n'est pas donné ; on y place le pied de page
-- du cours (un `footer:` explicite reste prioritaire)
local function Div(el)
  if footer and el.classes:includes("footer-default") and #el.content == 0 then
    el.content = { pandoc.Plain(footer) }
    return el
  end
end

-- revealjs : `{.allowframebreaks}` (coupure automatique en Beamer) devient
-- une diapositive défilante
local function Header(el)
  if quarto.doc.is_format("revealjs") and el.level == 2
      and el.classes:includes("allowframebreaks") then
    el.classes:insert("scrollable")
    return el
  end
end

-- revealjs : un titre « ### » et le contenu qui le suit forment un bloc,
-- comme dans Beamer (classes .alert et .example reprises)
local function Blocks(blocks)
  if not quarto.doc.is_format("revealjs") then
    return nil
  end
  local result = pandoc.Blocks({})
  local block = nil
  for _, el in ipairs(blocks) do
    local starts = el.t == "Header" and el.level <= 3
    if block and (starts or el.t == "HorizontalRule") then
      result:insert(block)
      block = nil
    end
    if el.t == "Header" and el.level == 3 then
      local classes = { "hearc-block" }
      for _, c in ipairs({ "alert", "example" }) do
        if el.classes:includes(c) then
          table.insert(classes, c)
        end
      end
      -- Titre en paragraphe : un Div commençant par un titre deviendrait une
      -- <section>, que reveal.js prendrait pour une diapositive imbriquée
      local title = pandoc.Div({ pandoc.Plain(el.content) }, { class = "hearc-block-title" })
      block = pandoc.Div({ title }, { class = table.concat(classes, " ") })
    elseif block then
      block.content:insert(el)
    else
      result:insert(el)
    end
  end
  if block then
    result:insert(block)
  end
  return result
end

-- Meta d'abord : le pied de page doit être calculé avant le parcours des Div
return {
  { Meta = Meta },
  { Div = Div, Header = Header, Blocks = Blocks },
}
