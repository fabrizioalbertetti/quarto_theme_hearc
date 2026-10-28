-- Transmet les paramètres communs du cours (clé `course` de _quarto.yml)
-- au thème Beamer HE-Arc, sous forme de macros LaTeX dans le préambule.

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

function Meta(meta)
  if not quarto.doc.is_format("beamer") then
    return meta
  end

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

  return meta
end
