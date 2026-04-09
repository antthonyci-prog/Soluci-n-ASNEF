$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$site = [ordered]@{
  Name = 'Solución ASNEF'
  Domain = 'solucionasnef.com'
  Url = 'https://www.solucionasnef.com'
  Email = 'contacto@solucionasnef.com'
  PrivacyEmail = 'privacidad@solucionasnef.com'
  Phone = '+34 660566880'
  Owner = 'Anthony Correa Iser'
  TaxId = '60535430M'
  Address = 'C. los Perales, 3, 35018 Las Palmas de Gran Canaria, Las Palmas'
  FormResponse = '24 horas laborables'
  Description = 'Portal informativo sobre ASNEF, ficheros de solvencia, negociación de deudas y derechos del consumidor en España.'
  OgImage = 'https://www.solucionasnef.com/logo-icono.png'
}

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  $dir = Split-Path -Parent $Path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Join-Url {
  param([string]$RelativePath)
  $clean = $RelativePath.Replace('\', '/').TrimStart('/')
  if ($clean -eq 'index.html') {
    return $site.Url
  }
  return "$($site.Url.TrimEnd('/'))/$clean"
}

function Prefix-For {
  param([string]$RelativePath)
  if ($RelativePath -match '^(pages|legal|articulos|admin|cuenta)[\\/].+') {
    return '../'
  }
  return ''
}

function Get-RelativeHref {
  param(
    [string]$FromRelativePath,
    [string]$ToRelativePath
  )

  $siteRoot = "$($site.Url.TrimEnd('/'))/"
  $fromPath = ($FromRelativePath -replace '\\', '/').TrimStart('/')
  $toPath = ($ToRelativePath -replace '\\', '/').TrimStart('/')
  $fromDir = Split-Path -Path $fromPath -Parent

  $baseUri = if ([string]::IsNullOrWhiteSpace($fromDir)) {
    [System.Uri]::new($siteRoot)
  }
  else {
    [System.Uri]::new("$siteRoot$($fromDir.TrimEnd('/'))/")
  }

  $targetUri = [System.Uri]::new("$siteRoot$toPath")
  return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString())
}

function Nav-Class {
  param([string]$ActiveKey, [string]$Key)
  if ($ActiveKey -eq $Key) { return 'nav-item active' }
  return 'nav-item'
}

function Nav-Cta-Class {
  param([string]$ActiveKey)
  if ($ActiveKey -eq 'contact') { return 'nav-item nav-item-cta active' }
  return 'nav-item nav-item-cta'
}

function Header-Html {
  param(
    [string]$Prefix,
    [string]$ActiveKey
  )

  @"
<header class="site-header">
  <div class="container header-inner">
    <div class="brand-wrap">
      <a class="brand" href="${Prefix}index.html">
        <span class="brand-copy">
          <span data-site-name>$($site.Name)</span>
          <span class="brand-note">Información clara, trazable y sin promesas agresivas.</span>
        </span>
      </a>
    </div>
    <button class="nav-toggle" aria-expanded="false" aria-controls="site-nav">Menú</button>
    <nav id="site-nav" class="site-nav" aria-label="Principal">
      <a href="${Prefix}index.html" class="$(Nav-Class $ActiveKey 'home')">Inicio</a>
      <a href="${Prefix}pages/salir-de-asnef.html" class="$(Nav-Class $ActiveKey 'salir')">Salir de ASNEF</a>
      <a href="${Prefix}pages/consultar-asnef.html" class="$(Nav-Class $ActiveKey 'consultar')">Consultar ASNEF</a>
      <a href="${Prefix}pages/derechos-usuario.html" class="$(Nav-Class $ActiveKey 'derechos')">Derechos</a>
      <a href="${Prefix}articulos/index.html" class="$(Nav-Class $ActiveKey 'blog')">Artículos</a>
      <a href="${Prefix}pages/sobre-nosotros.html" class="$(Nav-Class $ActiveKey 'about')">Sobre nosotros</a>
      <a href="${Prefix}pages/contacto.html" class="$(Nav-Cta-Class $ActiveKey)">Consultar caso</a>
    </nav>
  </div>
</header>
"@
}

function Footer-Html {
  param([string]$Prefix)

  @"
<footer class="site-footer">
  <div class="container footer-grid">
    <div>
      <a class="brand brand-footer" href="${Prefix}index.html"><span data-site-name>$($site.Name)</span></a>
      <p>Web editorial e informativa orientada a personas que necesitan entender ASNEF, revisar una deuda y decidir el siguiente paso con calma.</p>
    </div>
    <div>
      <h2>Servicios editoriales</h2>
      <ul class="footer-links">
        <li><a href="${Prefix}pages/salir-de-asnef.html">Salir de ASNEF</a></li>
        <li><a href="${Prefix}pages/consultar-asnef.html">Consultar ASNEF</a></li>
        <li><a href="${Prefix}pages/derechos-usuario.html">Derechos del usuario</a></li>
        <li><a href="${Prefix}articulos/index.html">Centro de contenidos</a></li>
      </ul>
    </div>
    <div>
      <h2>Transparencia</h2>
      <ul class="footer-links">
        <li><a href="${Prefix}legal/aviso-legal.html">Aviso legal</a></li>
        <li><a href="${Prefix}legal/politica-privacidad.html">Política de privacidad</a></li>
        <li><a href="${Prefix}legal/politica-cookies.html">Política de cookies</a></li>
        <li><a href="${Prefix}legal/terminos-condiciones.html">Condiciones de uso</a></li>
      </ul>
    </div>
    <div>
      <h2>Contacto</h2>
      <ul class="footer-links">
        <li><a data-public-email-link href="mailto:$($site.Email)">$($site.Email)</a></li>
        <li><a data-public-phone-link href="tel:$($site.Phone)">$($site.Phone)</a></li>
        <li><a href="${Prefix}pages/contacto.html">Formulario seguro</a></li>
        <li><a href="${Prefix}pages/sobre-nosotros.html">Quién firma el contenido</a></li>
      </ul>
    </div>
  </div>
  <p class="footer-bottom">© <span data-current-year></span> <span data-site-name>$($site.Name)</span>. Todos los derechos reservados.</p>
</footer>
"@
}

function Breadcrumb-Html {
  param([array]$Crumbs)

  $items = foreach ($crumb in $Crumbs) {
    if ($crumb.href) {
      "<a href=""$($crumb.href)"">$([System.Net.WebUtility]::HtmlEncode($crumb.label))</a>"
    }
    else {
      [System.Net.WebUtility]::HtmlEncode($crumb.label)
    }
  }

  '<p class="breadcrumbs">' + ($items -join ' / ') + '</p>'
}

function Breadcrumb-JsonLd {
  param([array]$Crumbs)

  $items = @()
  $position = 1
  foreach ($crumb in $Crumbs) {
    $abs = if ($crumb.absolute) { $crumb.absolute } elseif ($crumb.href) { Join-Url ($crumb.href.Replace('../', '').TrimStart('/')) } else { '' }
    $items += [ordered]@{
      '@type' = 'ListItem'
      position = $position
      name = $crumb.label
      item = $abs
    }
    $position++
  }

  return @{
    '@context' = 'https://schema.org'
    '@type' = 'BreadcrumbList'
    itemListElement = $items
  } | ConvertTo-Json -Depth 8 -Compress
}

function Organization-JsonLd {
  return @{
    '@context' = 'https://schema.org'
    '@type' = 'Organization'
    name = $site.Name
    url = $site.Url
    logo = $site.OgImage
    email = $site.Email
    telephone = $site.Phone
  } | ConvertTo-Json -Depth 8 -Compress
}

function Faq-JsonLd {
  param([array]$Faqs)
  return @{
    '@context' = 'https://schema.org'
    '@type' = 'FAQPage'
    mainEntity = @(
      foreach ($faq in $Faqs) {
        @{
          '@type' = 'Question'
          name = $faq.q
          acceptedAnswer = @{
            '@type' = 'Answer'
            text = $faq.a
          }
        }
      }
    )
  } | ConvertTo-Json -Depth 8 -Compress
}

function Article-JsonLd {
  param(
    [hashtable]$Page,
    [string]$RelativePath
  )

  return @{
    '@context' = 'https://schema.org'
    '@type' = 'Article'
    headline = $Page.Title
    description = $Page.Description
    datePublished = $Page.Published
    dateModified = $Page.Published
    author = @{
      '@type' = 'Person'
      name = $site.Owner
    }
    publisher = @{
      '@type' = 'Organization'
      name = $site.Name
      logo = @{
        '@type' = 'ImageObject'
        url = $site.OgImage
      }
    }
    mainEntityOfPage = Join-Url $RelativePath
    image = $site.OgImage
    articleSection = $Page.Category
  } | ConvertTo-Json -Depth 8 -Compress
}

function Build-Head {
  param(
    [string]$Title,
    [string]$Description,
    [string]$Prefix,
    [string]$Robots,
    [string]$CanonicalUrl,
    [array]$JsonLdBlocks
  )

  $schemaBlock = ''
  if ($JsonLdBlocks -and $JsonLdBlocks.Count -gt 0) {
    $schemaBlock = (($JsonLdBlocks | Where-Object { $_ }) | ForEach-Object { "<script type=""application/ld+json"">$($_)</script>" }) -join "`n  "
  }
@"
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>$([System.Net.WebUtility]::HtmlEncode($Title))</title>
  <meta name="description" content="$([System.Net.WebUtility]::HtmlEncode($Description))" />
  <meta name="robots" content="$Robots" />
  <meta name="theme-color" content="#174c8f" />
  <meta property="og:type" content="website" />
  <meta property="og:locale" content="es_ES" />
  <meta property="og:title" content="$([System.Net.WebUtility]::HtmlEncode($Title))" />
  <meta property="og:description" content="$([System.Net.WebUtility]::HtmlEncode($Description))" />
  <meta property="og:url" content="$CanonicalUrl" />
  <meta property="og:site_name" content="$([System.Net.WebUtility]::HtmlEncode($site.Name))" />
  <meta property="og:image" content="$($site.OgImage)" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="canonical" href="$CanonicalUrl" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Merriweather:wght@700&display=swap" rel="stylesheet" />
  <link rel="icon" href="${Prefix}logo-icono.png" type="image/png" />
  <link rel="stylesheet" href="${Prefix}styles.css" />
  $schemaBlock
</head>
"@
}

function Page-Shell {
  param(
    [string]$RelativePath,
    [string]$BodyClass,
    [string]$Title,
    [string]$Description,
    [string]$ActiveKey,
    [string]$MainContent,
    [string]$Robots = 'index, follow',
    [array]$JsonLdBlocks = @()
  )

  $prefix = Prefix-For $RelativePath
  $canonicalUrl = Join-Url $RelativePath
@"
<!DOCTYPE html>
<html lang="es">
$(Build-Head -Title $Title -Description $Description -Prefix $prefix -Robots $Robots -CanonicalUrl $canonicalUrl -JsonLdBlocks $JsonLdBlocks)
<body class="$BodyClass">
  $(Header-Html -Prefix $prefix -ActiveKey $ActiveKey)
  $MainContent
  $(Footer-Html -Prefix $prefix)
  <script src="${prefix}site-config.js"></script>
  <script src="${prefix}lead-config.js"></script>
  <script src="${prefix}script.js"></script>
</body>
</html>
"@
}

function Section-Html {
  param([hashtable]$Section)

  $paragraphs = ($Section.Paragraphs | ForEach-Object { "<p>$([System.Net.WebUtility]::HtmlEncode($_))</p>" }) -join "`n"
  $list = ''
  if ($Section.List -and $Section.List.Count -gt 0) {
    $items = ($Section.List | ForEach-Object { "<li>$([System.Net.WebUtility]::HtmlEncode($_))</li>" }) -join ''
    $list = "<ul>$items</ul>"
  }

@"
<section id="$($Section.Id)">
  <h2>$([System.Net.WebUtility]::HtmlEncode($Section.Title))</h2>
  $paragraphs
  $list
</section>
"@
}

function Faq-Html {
  param([array]$Faqs)

  $items = foreach ($faq in $Faqs) {
@"
<details>
  <summary>$([System.Net.WebUtility]::HtmlEncode($faq.q))</summary>
  <p>$([System.Net.WebUtility]::HtmlEncode($faq.a))</p>
</details>
"@
  }

@"
<section class="faq-list" aria-label="Preguntas frecuentes">
  $($items -join "`n")
</section>
"@
}

function Ad-SlotHtml {
  param(
    [string]$SlotKey = 'inContentSlot',
    [string]$AriaLabel = 'Publicidad',
    [string]$Title = 'Espacio preparado para un bloque publicitario integrado.',
    [string]$Meta = 'La publicidad se mantiene separada del contenido editorial.',
    [string]$Classes = 'ad-slot-inline',
    [string]$Format = 'auto'
  )

  $classNames = @('ad-slot')
  if ($Classes) {
    $classNames += (($Classes -split '\s+') | Where-Object { $_ })
  }

  $classAttr = $classNames -join ' '

@"
<aside class="$classAttr" aria-label="$([System.Net.WebUtility]::HtmlEncode($AriaLabel))" data-ad-slot-key="$SlotKey" data-ad-format="$Format">
  <p class="ad-slot-label">Publicidad</p>
  <div class="ad-slot-shell">
    <p class="ad-slot-copy">$([System.Net.WebUtility]::HtmlEncode($Title))</p>
    <p class="ad-slot-meta">$([System.Net.WebUtility]::HtmlEncode($Meta))</p>
  </div>
</aside>
"@
}

function Related-Html {
  param(
    [string]$Prefix,
    [array]$Related
  )

  $items = foreach ($link in $Related) {
    "<li><a href=""$Prefix$($link.href)"">$([System.Net.WebUtility]::HtmlEncode($link.label))</a></li>"
  }

@"
<div class="content-sidebar content-sidebar-stack">
  <p class="eyebrow">Ruta de lectura</p>
  <h3>Continúa por aquí</h3>
  <ul>
    $($items -join "`n")
  </ul>
  <div class="callout-box" style="margin-top: 1rem">
    <strong>Consulta inicial</strong>
    <p>Si prefieres ordenar tu caso con una primera revisión humana, utiliza el formulario y resume la deuda, la fecha y la documentación disponible.</p>
    <a class="button button-primary" href="${Prefix}pages/contacto.html">Enviar consulta</a>
  </div>
  $(Ad-SlotHtml -SlotKey 'inContentSlot' -AriaLabel 'Publicidad lateral' -Title 'Bloque lateral listo para acompañar la ruta de lectura sin competir con el contenido principal.' -Meta 'Puede reutilizar el slot intermedio o uno específico si lo configuras más adelante.' -Classes 'ad-slot-compact')
</div>
"@
}

function Render-EditorialPage {
  param(
    [hashtable]$Page,
    [string]$RelativePath,
    [string]$ActiveKey,
    [string]$Kind
  )

  $prefix = Prefix-For $RelativePath
  $sectionsHtml = ($Page.Sections | ForEach-Object { Section-Html $_ }) -join "`n"
  $faqHtml = Faq-Html $Page.Faqs
  $breadcrumbs = @(
    @{ label = 'Inicio'; href = "${prefix}index.html"; absolute = $site.Url }
  )

  if ($RelativePath.StartsWith('articulos/')) {
    $breadcrumbs += @{ label = 'Artículos'; href = "${prefix}articulos/index.html"; absolute = (Join-Url 'articulos/index.html') }
  }
  elseif ($RelativePath.StartsWith('pages/')) {
    $breadcrumbs += @{ label = 'Guías'; href = "${prefix}pages/salir-de-asnef.html"; absolute = (Join-Url 'pages/salir-de-asnef.html') }
  }

  $breadcrumbs += @{ label = $Page.Title; href = ''; absolute = (Join-Url $RelativePath) }

  $jsonLdParts = @(
    Organization-JsonLd
    (Breadcrumb-JsonLd $breadcrumbs)
    (Faq-JsonLd $Page.Faqs)
  )

  if ($Kind -eq 'article') {
    $jsonLdParts += (Article-JsonLd -Page $Page -RelativePath $RelativePath)
  }

  $main = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container page-hero-grid">
      <div class="panel page-hero-copy">
        $(Breadcrumb-Html $breadcrumbs)
        <p class="eyebrow accent">$([System.Net.WebUtility]::HtmlEncode($Page.Eyebrow))</p>
        <h1>$([System.Net.WebUtility]::HtmlEncode($Page.Headline))</h1>
        <p class="content-lead">$([System.Net.WebUtility]::HtmlEncode($Page.Lead))</p>
        <div class="content-meta">
          <span>$([System.Net.WebUtility]::HtmlEncode($Page.Category))</span>
          <span>$([System.Net.WebUtility]::HtmlEncode($Page.ReadTime))</span>
          <span>$([System.Net.WebUtility]::HtmlEncode($Page.Published))</span>
        </div>
        <div class="hero-actions">
          <a class="button button-primary" href="${prefix}pages/contacto.html">Consultar mi caso</a>
          <a class="button button-secondary" href="${prefix}articulos/index.html">Ver más contenidos</a>
        </div>
      </div>
      <aside class="content-sidebar">
        <p class="eyebrow">Resumen ejecutivo</p>
        <h3>$([System.Net.WebUtility]::HtmlEncode($Page.SideTitle))</h3>
        <p>$([System.Net.WebUtility]::HtmlEncode($Page.SideText))</p>
        <div class="content-toc">
          <a href="#revisar">Qué revisar</a>
          <a href="#actuar">Cómo actuar</a>
          <a href="#documentacion">Documentación útil</a>
          <a href="#errores">Errores frecuentes</a>
          <a href="#criterio">Cómo usar esta guía</a>
          <a href="#faq">Preguntas frecuentes</a>
        </div>
      </aside>
    </div>
  </section>

  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-shell">
          $(Ad-SlotHtml -SlotKey 'topBannerSlot' -AriaLabel 'Publicidad superior del artículo' -Title 'Bloque superior preparado para monetizar el arranque del artículo sin romper el contexto editorial.' -Meta 'Se sitúa después del hero y antes del desarrollo largo para mantener una entrada limpia.' -Classes 'ad-slot-wide')
          <p class="content-intro">$([System.Net.WebUtility]::HtmlEncode($Page.Lead2))</p>
          <div class="content-body">
            $sectionsHtml
            <section id="criterio">
              <h2>Cómo utilizar esta información con criterio</h2>
              <p>Esta guía está pensada para ayudarte a distinguir entre dato, prueba y decisión. En expedientes relacionados con $([System.Net.WebUtility]::HtmlEncode($Page.Category.ToLower())), la urgencia suele empujar a buscar una respuesta cerrada en muy poco tiempo, pero lo que realmente reduce errores es reconstruir bien el caso y dejar por escrito cada paso.</p>
              <p>Si tu prioridad es financiación, contratación de servicios o regularización rápida, usa esta lectura como mapa de trabajo: ordena fechas, conserva comunicaciones y evita comprometerte con llamadas o promesas poco trazables. Esa disciplina documental suele marcar la diferencia entre una gestión improvisada y una decisión sólida.</p>
            </section>
            <section id="faq">
              <h2>Preguntas frecuentes</h2>
              $faqHtml
            </section>
          </div>
          $(Ad-SlotHtml -SlotKey 'inContentSlot' -AriaLabel 'Publicidad intermedia del artículo' -Title 'Bloque intermedio pensado para una segunda impresión visible cuando la lectura ya está madura.' -Meta 'Añade inventario publicitario sin cortar la comprensión del problema ni la navegación por apartados.' -Classes 'ad-slot-inline')
          <div class="content-checklist">
            <p class="eyebrow">Siguiente paso razonable</p>
            <h3>$([System.Net.WebUtility]::HtmlEncode($Page.NextTitle))</h3>
            <p>$([System.Net.WebUtility]::HtmlEncode($Page.NextText))</p>
          </div>
          $(Ad-SlotHtml -SlotKey 'bottomSlot' -AriaLabel 'Publicidad final del artículo' -Title 'Bloque final listo para monetizar el cierre del artículo y la transición a la siguiente lectura.' -Meta 'Mantiene la separación entre contenido editorial y publicidad en una zona menos invasiva.' -Classes 'ad-slot-inline')
        </div>
      </article>
      $(Related-Html -Prefix $prefix -Related $Page.Related)
    </div>
  </section>
</main>
"@

  return Page-Shell -RelativePath $RelativePath -BodyClass $Page.BodyClass -Title $Page.Title -Description $Page.Description -ActiveKey $ActiveKey -MainContent $main -JsonLdBlocks $jsonLdParts
}

function New-TopicArticle {
  param(
    [string]$Path,
    [string]$Title,
    [string]$Description,
    [string]$Category,
    [string]$Eyebrow,
    [string]$Headline,
    [string]$Lead,
    [string]$Lead2,
    [string]$SideTitle,
    [string]$SideText,
    [string]$ReviewPoint,
    [string]$ContextPoint,
    [string]$ActionPoint,
    [string]$DecisionPoint,
    [string]$DocsIntro,
    [array]$DocumentList,
    [string]$MistakeIntro,
    [array]$MistakeList,
    [string]$NextTitle,
    [string]$NextText,
    [array]$Faqs,
    [array]$Related,
    [string]$ReadTime = '11 min de lectura'
  )

  return [ordered]@{
    Path = $Path
    Title = $Title
    Description = $Description
    Eyebrow = $Eyebrow
    Headline = $Headline
    Lead = $Lead
    Lead2 = $Lead2
    Category = $Category
    ReadTime = $ReadTime
    Published = '2026-04-01'
    SideTitle = $SideTitle
    SideText = $SideText
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{
        Id = 'revisar'
        Title = 'Qué revisar antes de mover ficha'
        Paragraphs = @(
          "Cuando una búsqueda gira alrededor de $Category, casi nunca basta con una respuesta rápida. Lo útil es ubicar primero el expediente real: entidad implicada, fecha del problema, importe, comunicaciones previas y objetivo inmediato. $ReviewPoint",
          "El contexto también importa. $ContextPoint Muchas decisiones se complican porque se mezclan deudas distintas, se confunden plazos o se da por hecho que una sola llamada aclarará lo que en realidad exige soporte escrito y una lectura más tranquila.",
          "Otra revisión clave consiste en separar lo que sabes con certeza de lo que solo recuerdas. En asuntos de solvencia, pagos, reclamaciones o cancelaciones, la memoria ayuda poco si luego no puedes conectar cada hecho con una referencia verificable."
        )
        List = @()
      }
      @{
        Id = 'actuar'
        Title = 'Cómo actuar con criterio y sin acelerar el error'
        Paragraphs = @(
          $ActionPoint,
          $DecisionPoint,
          "Si intervienen teléfono, correo electrónico y formularios, procura dejar un rastro mínimo de todo. Anotar fechas, persona o departamento contactado y resumen de la respuesta suele ahorrar más tiempo del que parece, sobre todo cuando después necesitas insistir, reclamar o demostrar que ya regularizaste la situación."
        )
        List = @()
      }
      @{
        Id = 'documentacion'
        Title = 'Documentación que conviene reunir'
        Paragraphs = @(
          $DocsIntro,
          "No hace falta construir un expediente infinito. Suele funcionar mejor una carpeta breve, bien ordenada y fechada, con documentos legibles y una cronología simple que permita entender de dónde viene el problema y qué esperas conseguir a continuación."
        )
        List = $DocumentList
      }
      @{
        Id = 'errores'
        Title = 'Errores frecuentes que alargan el expediente'
        Paragraphs = @(
          $MistakeIntro,
          "La pauta se repite bastante: urgencia alta, documentación desordenada y expectativas mal calibradas. En cambio, cuando la persona entiende qué quiere demostrar, qué canal tiene sentido y qué prueba debe guardar, el caso suele avanzar con menos fricción."
        )
        List = $MistakeList
      }
    )
    NextTitle = $NextTitle
    NextText = $NextText
    Faqs = $Faqs
    Related = $Related
  }
}

$categoryPages = @(
  [ordered]@{
    Path = 'pages/salir-de-asnef.html'
    Title = 'Salir de ASNEF: guía práctica para revisar deuda, pago y cancelación'
    Description = 'Qué hacer si quieres salir de ASNEF sin precipitarte: revisar la deuda, acreditar pagos, reclamar errores y entender cuándo procede la baja.'
    Eyebrow = 'Categoría principal'
    Headline = 'Salir de ASNEF exige método, no atajos.'
    Lead = 'La mayoría de problemas no empiezan con el fichero, sino con una deuda mal entendida, una negociación mal cerrada o un pago que no quedó trazado. Si lo ordenas bien desde el principio, la salida suele ser mucho más rápida y con menos desgaste.'
    Lead2 = 'Esta guía reúne la información básica que conviene revisar antes de llamar, pagar, firmar o reclamar. El objetivo no es vender una solución automática, sino ayudarte a reducir errores de calendario, de documentación y de expectativas.'
    Category = 'Salir de ASNEF'
    ReadTime = '11 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Qué busca esta ruta'
    SideText = 'Te orienta cuando el problema central es la baja del fichero, no solo la financiación perdida. Se centra en deuda, pruebas y tiempos.'
    BodyClass = 'theme-home page-guide'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué revisar antes de pedir la baja'; Paragraphs = @(
        'Antes de hablar de cancelación, conviene identificar tres cosas: quién comunicó la deuda, qué importe exacto figura y qué hechos pueden demostrar si el dato sigue siendo válido. Muchas personas se enfocan solo en la angustia de aparecer en ASNEF, pero el trabajo útil empieza al reconstruir la cronología del impago y de las comunicaciones recibidas.',
        'Si existe carta de inclusión, justificantes de pago, correos del acreedor o incidencias abiertas, ordénalos por fecha. Esa trazabilidad te permite distinguir entre un caso de pago ya realizado, un caso de deuda discutida y un caso de deuda aún pendiente donde la salida depende de regularizar antes con el acreedor.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo actuar sin empeorar la posición'; Paragraphs = @(
        'Pagar deprisa puede ser razonable en algunos supuestos, pero no siempre es el primer paso. Si la deuda es dudosa, si el importe no coincide o si el acreedor no acredita bien el origen del saldo, lo prudente es aclararlo antes. La prisa por desaparecer del fichero no debería llevarte a reconocer importes que no controlas.',
        'Cuando el importe es correcto y el pago forma parte de la solución, guarda justificantes completos y solicita confirmación escrita. Si el conflicto está en la validez del dato, la vía puede pasar por el ejercicio de derechos y por reclamar ante la entidad que informó. La clave es no mezclar negociación, prueba y cancelación como si fueran lo mismo.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Documentación útil para ordenar el caso'; Paragraphs = @(
        'En un procedimiento informativo o en una consulta previa, suele ser más útil un expediente corto y claro que una carpeta llena de documentos sin contexto. Reúne aquello que explique el origen, la evolución y el estado actual del problema.'
      ); List = @(
        'Carta de inclusión o referencia recibida del fichero.',
        'Contrato, factura o documento que origina la deuda.',
        'Justificantes de pago parciales o totales.',
        'Correos, SMS o reclamaciones cruzadas con el acreedor.',
        'Cualquier contestación donde la entidad reconozca incidencias o revisiones internas.'
      ) }
      @{ Id = 'errores'; Title = 'Errores frecuentes al intentar salir de ASNEF'; Paragraphs = @(
        'Los errores más comunes no suelen ser jurídicos, sino prácticos. Se envía documentación sin orden, se llama a varios sitios sin anotar nada, se acepta una propuesta verbal y después cuesta demostrarla, o se da por hecho que pagar implica baja inmediata sin revisar los plazos y los flujos internos entre acreedor y fichero.'
      ); List = @(
        'Confiar en promesas verbales de baja sin soporte escrito.',
        'Pagar sin conservar justificantes completos.',
        'Discutir importes en llamadas y no por canales trazables.',
        'Esperar una respuesta instantánea cuando intervienen acreedor y fichero.'
      ) }
    )
    NextTitle = 'Qué hacer hoy si tu prioridad es salir del fichero'
    NextText = 'Empieza por una cronología simple: fecha de impago, fecha de inclusión, estado real de la deuda y pruebas disponibles. Con eso ya puedes decidir si corresponde pagar, reclamar, negociar o exigir la rectificación.'
    Faqs = @(
      @{ q = '¿Pagar siempre implica salir de ASNEF al instante?'; a = 'No necesariamente. El pago ayuda a la baja, pero la actualización del dato requiere tramitación entre quien informó y el sistema de información crediticia.' },
      @{ q = '¿Puedo reclamar si no reconozco la deuda?'; a = 'Sí. Si el importe o el origen son discutidos, conviene documentarlo y revisar el cauce de reclamación con el acreedor y, si procede, con el fichero.' },
      @{ q = '¿Sirve con una captura de banca móvil como prueba de pago?'; a = 'Puede ayudar, pero lo recomendable es conservar justificantes completos donde consten fecha, emisor, destinatario, importe y concepto.' }
    )
    Related = @(
      @{ href = 'pages/consultar-asnef.html'; label = 'Cómo consultar tus datos en ASNEF' },
      @{ href = 'pages/derechos-usuario.html'; label = 'Derechos del usuario ante un fichero de solvencia' },
      @{ href = 'articulos/cancelar-asnef-despues-de-pagar.html'; label = 'Cancelar ASNEF después de pagar' }
    )
  },
  [ordered]@{
    Path = 'pages/consultar-asnef.html'
    Title = 'Consultar ASNEF: cómo comprobar si estás incluido y qué necesitas'
    Description = 'Guía para consultar ASNEF, identificar la referencia correcta y distinguir entre acceso informativo, revisión de deuda y solicitud de rectificación.'
    Eyebrow = 'Categoría principal'
    Headline = 'Consultar ASNEF no es solo mirar si apareces.'
    Lead = 'Una consulta bien hecha no sirve únicamente para confirmar si tu nombre figura en el fichero. También te permite entender qué deuda está asociada, desde cuándo, quién la comunicó y qué pasos tienen sentido a continuación.'
    Lead2 = 'Muchas búsquedas nacen con urgencia porque la financiación se ha bloqueado o una operación no avanza. Precisamente por eso conviene entrar a la consulta con criterio: saber qué dato buscas, qué documentos pueden ayudarte y qué conclusiones todavía no debes sacar.'
    Category = 'Consultar ASNEF'
    ReadTime = '10 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Objetivo de la consulta'
    SideText = 'Confirmar inclusión, identificar la deuda, localizar la referencia útil y preparar el siguiente paso con información verificable.'
    BodyClass = 'theme-home page-guide'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué necesitas para consultar correctamente'; Paragraphs = @(
        'Lo más práctico es empezar por la carta de inclusión, si la tienes. En la información pública de ASNEF se explica que a través de la plataforma de derechos del fichero puede ejercerse el acceso y que, en muchos casos, se solicita la referencia de la carta para localizar el expediente con más rapidez. Si no dispones de ella, no significa que no puedas ordenar el caso, pero sí que tendrás que documentarte mejor.',
        'La consulta útil no persigue confirmar un rumor, sino obtener un dato accionable. Por eso es importante tener a mano el documento de identidad, la referencia si existe, cualquier comunicación del acreedor y una nota breve con las incidencias abiertas. Eso evita duplicidades y respuestas genéricas.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo interpretar la respuesta'; Paragraphs = @(
        'Saber que apareces en ASNEF no equivale a saber qué hacer. La respuesta puede abrir escenarios distintos: deuda correcta y pendiente, deuda ya pagada pero no actualizada, importe discutido o incluso necesidad de pedir más información al acreedor antes de mover ficha. La consulta es una puerta de entrada, no el final del análisis.',
        'Desde la propia información pública del fichero se recuerda además que el RGPD establece un plazo general de respuesta de un mes para solicitudes de derechos, prorrogable en casos complejos. Ese dato ayuda a ajustar expectativas y evita la falsa idea de que todo debe resolverse el mismo día.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Qué conviene guardar después de consultar'; Paragraphs = @(
        'Una vez recibida la respuesta, crea un expediente sencillo. Lo útil es que cualquier tercero que revise tu situación pueda entenderla en pocos minutos sin interpretar archivos sueltos.'
      ); List = @(
        'Copia de la respuesta de acceso o captura completa del resultado.',
        'Datos del acreedor o entidad informante.',
        'Importe comunicado y fecha de vencimiento asociada.',
        'Referencia del expediente y canal utilizado para la consulta.'
      ) }
      @{ Id = 'errores'; Title = 'Errores frecuentes al buscar opciones de consulta'; Paragraphs = @(
        'Hay mucho contenido de terceros que promete comprobaciones exprés o acceso inmediato a cambio de datos sensibles. La prudencia aquí importa. Cuando la prioridad es confirmar inclusión y preparar una defensa documental, conviene apoyarse en canales verificables y desconfiar de atajos poco claros.'
      ); List = @(
        'Dar por válido cualquier resultado sin contrastar su origen.',
        'Compartir documentación sensible en webs que no identifican responsable.',
        'Confundir la asociación ASNEF con servicios de intermediación de terceros.',
        'Creer que consultar el fichero resuelve por sí mismo la incidencia.'
      ) }
    )
    NextTitle = 'Qué hacer tras confirmar la inclusión'
    NextText = 'Ordena la deuda, comprueba si existe pago o disputa y decide si el caso exige negociación con el acreedor, rectificación, baja tras pago o simple seguimiento.'
    Faqs = @(
      @{ q = '¿La consulta de ASNEF es gratuita?'; a = 'El ejercicio del derecho de acceso al fichero se plantea como un derecho del afectado. Lo importante es usar el canal correcto y no entregar datos a intermediarios opacos.' },
      @{ q = '¿Necesito la carta para consultar?'; a = 'La referencia de la carta ayuda mucho, pero si no la tienes aún puedes reconstruir el caso con tus comunicaciones y documentos de deuda.' },
      @{ q = '¿Puedo sacar conclusiones solo con ver que aparezco?'; a = 'No. Después de la consulta hay que revisar origen, fecha, importe y estado real de la deuda antes de decidir el siguiente movimiento.' }
    )
    Related = @(
      @{ href = 'articulos/como-comprobar-fichero-solvencia.html'; label = 'Cómo comprobar si apareces en un fichero de solvencia' },
      @{ href = 'articulos/asnef-gratis-consulta-opciones-reales.html'; label = 'Qué opciones reales existen para consultar' },
      @{ href = 'pages/salir-de-asnef.html'; label = 'Salir de ASNEF con un método ordenado' }
    )
  },
  [ordered]@{
    Path = 'pages/derechos-usuario.html'
    Title = 'Derechos del usuario en ASNEF: acceso, rectificación, cancelación y oposición'
    Description = 'Qué derechos puedes ejercer cuando tus datos aparecen en un fichero de solvencia y cómo prepararlos sin improvisar.'
    Eyebrow = 'Categoría principal'
    Headline = 'Tus derechos importan más que la prisa.'
    Lead = 'Cuando una persona aparece en un fichero de solvencia suele centrarse solo en la urgencia de borrar el dato. Sin embargo, la parte más importante es saber qué puedes pedir, en qué canal y con qué pruebas.'
    Lead2 = 'Los derechos de acceso, rectificación, supresión o limitación no funcionan como fórmulas mágicas. Necesitan una base documental clara y una estrategia coherente con el problema real. A veces lo correcto es acreditar un pago. Otras veces toca discutir el origen del dato.'
    Category = 'Derechos del usuario'
    ReadTime = '11 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'En qué casos usar esta guía'
    SideText = 'Especialmente útil si crees que el dato es incorrecto, si falta contexto en la deuda o si necesitas preparar una reclamación con base documental.'
    BodyClass = 'theme-home page-guide'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué derecho encaja con cada problema'; Paragraphs = @(
        'El derecho de acceso sirve para saber qué información aparece y cuál es su alcance. La rectificación encaja cuando el dato es inexacto o incompleto. La supresión o cancelación puede entrar en juego si ya no procede el tratamiento o si el pago y las circunstancias obligan a revisar la permanencia. El problema práctico es que muchas veces se pide una cosa cuando en realidad la incidencia era otra.',
        'La información pública del fichero recuerda además que las solicitudes de rectificación o supresión suelen requerir comprobación con la entidad informante. Por eso no siempre hay una respuesta inmediata: interviene quien aportó los datos y esa fase debe incorporarse a tus expectativas.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo preparar un ejercicio de derechos útil'; Paragraphs = @(
        'El enfoque eficaz combina claridad y prueba. Explica qué dato cuestionas, por qué entiendes que debe revisarse y qué documento sostiene tu postura. Evita escritos emocionales o demasiado largos. Una solicitud ordenada reduce idas y vueltas y hace más fácil que el responsable identifique el núcleo del problema.',
        'Si además has hablado con el acreedor, incorpora esa trazabilidad. Correos, números de incidencia, justificantes de transferencia o respuestas donde se reconoce una revisión interna pueden ser más valiosos que repetir varias veces la misma reclamación sin nuevas pruebas.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Pruebas que suelen marcar la diferencia'; Paragraphs = @(
        'No todos los casos exigen el mismo expediente, pero casi siempre ayudan los documentos que conectan deuda, fecha y estado actual de la relación con el acreedor.'
      ); List = @(
        'Documento de identidad del afectado o representación válida.',
        'Carta de inclusión o respuesta de acceso al fichero.',
        'Contrato, factura o soporte del importe reclamado.',
        'Justificantes de pago, abonos o acuerdos cerrados.',
        'Reclamaciones previas presentadas al acreedor y sus respuestas.'
      ) }
      @{ Id = 'errores'; Title = 'Errores que debilitan una reclamación'; Paragraphs = @(
        'Una reclamación pierde fuerza cuando no concreta el dato discutido, cuando no aporta prueba verificable o cuando pretende resolver por una sola vía un problema que también depende del acreedor. La consistencia documental importa más que la cantidad de mensajes enviados.'
      ); List = @(
        'Pedir cancelación sin explicar por qué el dato ya no procede.',
        'Aportar capturas sueltas sin fecha, emisor o concepto claro.',
        'No distinguir entre reclamación al acreedor y solicitud al fichero.',
        'Enviar varios escritos contradictorios en pocos días.'
      ) }
    )
    NextTitle = 'Qué hacer si no sabes qué derecho ejercitar'
    NextText = 'Empieza por acceso y por reconstruir el expediente. Después será más fácil decidir si toca rectificar, reclamar al acreedor, acreditar el pago o discutir la propia legitimidad del dato.'
    Faqs = @(
      @{ q = '¿Puedo pedir la cancelación solo porque me perjudica?'; a = 'No basta con que el dato sea incómodo. Debe existir una base material para revisar la procedencia, exactitud o permanencia del tratamiento.' },
      @{ q = '¿Quién decide finalmente si se corrige el dato?'; a = 'En muchas incidencias intervienen tanto el responsable del sistema como la entidad que comunicó la deuda, por eso la respuesta puede requerir comprobaciones previas.' },
      @{ q = '¿Sirve reclamar varias veces lo mismo?'; a = 'Solo si aportas información nueva o si cambia el estado del expediente. Repetir sin base adicional rara vez mejora el resultado.' }
    )
    Related = @(
      @{ href = 'pages/reclamar-asnef.html'; label = 'Guía práctica para reclamar errores en ASNEF' },
      @{ href = 'articulos/cancelar-asnef-despues-de-pagar.html'; label = 'Baja después del pago: cómo documentarla' },
      @{ href = 'pages/contacto.html'; label = 'Enviar una consulta inicial ordenada' }
    )
  }
)

$generatedArticlePages = @(
  [ordered]@{
    Path = 'articulos/como-comprobar-fichero-solvencia.html'
    Title = 'Cómo comprobar si estás en un fichero de solvencia sin caer en atajos'
    Description = 'Método práctico para verificar si apareces en un fichero de solvencia, ordenar la referencia correcta y preparar el siguiente paso.'
    Eyebrow = 'Artículo SEO'
    Headline = 'Comprobarlo bien te ahorra muchos errores después.'
    Lead = 'Cuando alguien sospecha que aparece en un fichero de solvencia suele entrar en modo urgencia. El problema es que la prisa favorece consultas mal hechas, páginas de terceros poco claras y decisiones precipitadas. Verificar el dato con criterio cambia mucho la calidad del siguiente paso.'
    Lead2 = 'Este artículo te propone un método de trabajo simple: identificar la vía de acceso, reunir la referencia útil, interpretar el resultado y guardar la información de manera que después sirva para reclamar, negociar o pedir la baja.'
    Category = 'Consulta de solvencia'
    ReadTime = '9 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Por qué leerlo'
    SideText = 'Porque confirmar la inclusión es importante, pero hacerlo con orden es lo que convierte esa comprobación en una herramienta real.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Empieza por la fuente y la referencia'; Paragraphs = @(
        'Lo más útil es apoyarte en la información que ya existe dentro del expediente. La carta de inclusión, si está disponible, suele ser el punto de partida más valioso porque te da una referencia trazable. En la FAQ pública del fichero ASNEF se explica que el acceso a los datos puede hacerse a través de la plataforma de gestión de derechos y que la referencia de la carta agiliza la localización del caso.',
        'Si no conservas esa comunicación, todavía puedes reconstruir la situación con otros elementos: correos del acreedor, denegaciones de financiación, fechas aproximadas de impago y cualquier aviso recibido. Lo importante es no sustituir la falta de documentación por intuiciones.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Qué debes mirar cuando recibes la respuesta'; Paragraphs = @(
        'La respuesta útil no es solo un sí o un no. Lo relevante es quién informa, qué importe figura, qué fecha aparece y si el estado del expediente encaja con tu propia documentación. Muchas incidencias se resuelven cuando se detecta una discrepancia concreta, no cuando se repite la angustia general.',
        'Una consulta bien guardada te ayuda además a medir plazos. La información pública del fichero recuerda que las solicitudes de derechos tienen, con carácter general, un mes de respuesta según el RGPD, con posibles prórrogas en casos complejos. Eso ayuda a evitar expectativas irreales.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Cómo guardar la consulta para que sirva después'; Paragraphs = @('No cierres la carpeta después de ver el resultado. Si más adelante necesitas reclamar, acreditar un pago o pedir ayuda, agradecerás tener un expediente corto y legible.'); List = @(
        'Resultado completo de la consulta o copia de la respuesta.',
        'Referencia o identificador del expediente.',
        'Nombre de la entidad informante.',
        'Fecha y canal por el que realizaste la consulta.'
      ) }
      @{ Id = 'errores'; Title = 'Errores frecuentes'; Paragraphs = @('La mayoría de problemas vienen de buscar una respuesta instantánea y no una respuesta fiable.'); List = @(
        'Consultar en páginas de terceros sin responsable identificado.',
        'No conservar la respuesta completa.',
        'Sacar conclusiones sin revisar importe y origen del dato.',
        'Creer que consultar ya resuelve el caso.'
      ) }
    )
    NextTitle = 'Qué hacer después de consultar'
    NextText = 'Si apareces, ordena la deuda, identifica si está pagada, discutida o pendiente y decide la vía adecuada. Si no apareces, conserva la prueba igualmente por si vuelves a necesitarla.'
    Faqs = @(
      @{ q = '¿Comprobar el fichero elimina la incidencia?'; a = 'No. Solo confirma y documenta el dato para decidir después la estrategia adecuada.' },
      @{ q = '¿Es mejor usar servicios de terceros?'; a = 'Solo si identifican claramente al responsable y el tratamiento. Cuando hay duda, es más prudente acudir a canales oficiales o verificables.' },
      @{ q = '¿Qué pasa si la respuesta no encaja con mi documentación?'; a = 'Esa discrepancia puede ser precisamente el núcleo de la reclamación o de la revisión posterior.' }
    )
    Related = @(
      @{ href = 'pages/consultar-asnef.html'; label = 'Guía completa para consultar ASNEF' },
      @{ href = 'pages/derechos-usuario.html'; label = 'Tus derechos sobre el dato consultado' },
      @{ href = 'articulos/asnef-gratis-consulta-opciones-reales.html'; label = 'Opciones reales para consultar gratis' }
    )
  },
  [ordered]@{
    Path = 'articulos/embargo-notificacion-que-revisar.html'
    Title = 'Notificación de embargo: qué revisar primero para no reaccionar en frío'
    Description = 'Claves para leer una notificación de embargo, ubicar la fase del expediente y decidir el siguiente paso con criterio.'
    Eyebrow = 'Artículo SEO'
    Headline = 'La primera lectura decide mucho más de lo que parece.'
    Lead = 'Una notificación de embargo suele llegar en el peor momento. Precisamente por eso la lectura inicial importa tanto. Si entiendes mal el documento, es fácil pagar lo que no toca, ignorar lo que sí requiere atención o pedir ayuda sin la información clave.'
    Lead2 = 'Este artículo resume una rutina de revisión útil: identificar emisor, cuantía, fase, plazos y relación con el resto del expediente de deuda.'
    Category = 'Embargos'
    ReadTime = '8 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Qué te llevas'
    SideText = 'Una lista corta de comprobaciones para que la presión del momento no sustituya a los hechos.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué datos no puedes pasar por alto'; Paragraphs = @(
        'Empieza por el emisor real del documento, la fecha, el número de expediente y el importe exigido. Después revisa si se habla de ejecución, de requerimiento previo, de diligencia concreta o de un acto puramente informativo. Las palabras importan porque marcan la fase del problema.',
        'También conviene comprobar si el importe coincide con lo que conocías y si existen referencias a documentos o reclamaciones anteriores. A veces la notificación revela que el caso lleva más recorrido del que pensabas.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo ordenar la reacción'; Paragraphs = @(
        'Reaccionar con orden significa conservar la notificación completa, resumir el caso en pocas líneas y decidir si necesitas una revisión urgente. Llamar antes de entender el documento puede generar ruido y compromisos mal explicados.',
        'Si además existe ASNEF, no mezcles ambos planos sin analizar. El fichero y el embargo pueden partir de la misma deuda, pero cada incidencia tiene su propia lógica y su propia documentación.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Pruebas que conviene reunir'; Paragraphs = @('Cuanto antes organices el expediente, mejor.'); List = @(
        'Notificación completa en PDF o copia íntegra.',
        'Soporte del origen de la deuda.',
        'Pagos realizados y acuerdos previos.',
        'Cualquier documento que muestre discrepancias de importe o fechas.'
      ) }
      @{ Id = 'errores'; Title = 'Errores que complican todo'; Paragraphs = @('En escenarios de tensión, los errores prácticos pesan mucho.'); List = @(
        'Quedarte solo con una foto parcial del documento.',
        'No anotar fechas ni referencias.',
        'Aceptar una explicación verbal sin soporte.',
        'Confundir presión comercial con trámite formal o viceversa.'
      ) }
    )
    NextTitle = 'Qué hacer si el documento te supera'
    NextText = 'Pide ayuda con la notificación completa, la deuda de origen y una cronología mínima. Esa preparación acelera mucho cualquier orientación útil.'
    Faqs = @(
      @{ q = '¿Debo responder el mismo día?'; a = 'Dependerá del contenido y de los plazos del documento, pero lo primero es entenderlo y conservarlo completo.' },
      @{ q = '¿Un embargo siempre viene después de ASNEF?'; a = 'No. Pueden coexistir por una misma deuda, pero no siguen necesariamente el mismo recorrido.' },
      @{ q = '¿Sirve una llamada para aclararlo todo?'; a = 'Puede orientar, pero no sustituye la lectura del documento ni la conservación de pruebas.' }
    )
    Related = @(
      @{ href = 'pages/embargos.html'; label = 'Guía extensa sobre embargos y deudas' },
      @{ href = 'pages/contacto.html'; label = 'Enviar notificación para revisión inicial' },
      @{ href = 'pages/negociar-deudas.html'; label = 'Negociar deuda con documentación ordenada' }
    )
  },
  [ordered]@{
    Path = 'articulos/salir-de-asnef-paso-a-paso.html'
    Title = 'Cómo salir de ASNEF paso a paso sin improvisar'
    Description = 'Ruta práctica para salir de ASNEF: consulta, verificación de deuda, pago o reclamación y seguimiento de la baja.'
    Eyebrow = 'Artículo SEO'
    Headline = 'Salir de ASNEF paso a paso es mucho más eficaz que buscar una solución instantánea.'
    Lead = 'Las búsquedas sobre salir de ASNEF suelen venir cargadas de urgencia. Tiene sentido: el fichero puede bloquear operaciones importantes. Pero precisamente por eso conviene seguir una secuencia razonable. Saltarse pasos suele alargar el problema.'
    Lead2 = 'Este artículo sintetiza una ruta práctica y realista: confirmar el dato, revisar la deuda, decidir si toca pagar o discutirla, acreditar lo hecho y hacer seguimiento hasta la actualización.'
    Category = 'Salir de ASNEF'
    ReadTime = '9 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'La idea clave'
    SideText = 'No se sale del fichero con una frase, sino con una cadena de acciones bien documentadas.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Paso 1: confirmar inclusión y datos básicos'; Paragraphs = @(
        'Antes de hacer nada, confirma si apareces y con qué información. El error típico es actuar sobre rumores o sobre una denegación de financiación sin haber visto todavía el dato exacto. Consulta quién informó, qué importe figura y desde cuándo.',
        'Ese paso te permite distinguir entre un problema de deuda pendiente, una deuda ya pagada, una discrepancia de importe o un caso donde falta documentación y aún no conviene mover ficha.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Paso 2: decidir si toca regularizar o reclamar'; Paragraphs = @(
        'Si la deuda es correcta y la regularización forma parte de la solución, documenta el pago con precisión y solicita confirmación. Si el problema está en el dato, prepara una reclamación con pruebas y evita aceptar soluciones verbales ambiguas.',
        'Muchas personas mezclan ambas cosas y pagan antes de aclarar una incidencia relevante. A veces eso cierra el caso; otras, lo complica. Por eso el orden importa.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Paso 3: acreditar todo lo hecho'; Paragraphs = @('Un caso bien documentado avanza mejor porque cada acción deja rastro.'); List = @(
        'Resultado de consulta o carta de inclusión.',
        'Justificante de pago completo, si existe.',
        'Correos con el acreedor o con el sistema de información.',
        'Resumen cronológico de actuaciones y respuestas.'
      ) }
      @{ Id = 'errores'; Title = 'Paso 4: no abandonar el seguimiento'; Paragraphs = @('Pagar o reclamar no cierra el caso por sí solo. Después hay que comprobar que el dato se ha actualizado y que no quedan referencias pendientes.'); List = @(
        'Dar por hecho que el pago ya ha resuelto la baja.',
        'No conservar el justificante final.',
        'No comprobar de nuevo el estado del expediente.',
        'Aceptar plazos inciertos sin confirmar el avance.'
      ) }
    )
    NextTitle = 'Qué deberías hacer hoy'
    NextText = 'Si quieres salir de ASNEF, no empieces por la solución que te ofrecen terceros. Empieza por el dato, la deuda y la documentación que puedes acreditar.'
    Faqs = @(
      @{ q = '¿Cuánto se tarda en salir de ASNEF?'; a = 'Depende del estado del expediente, del canal utilizado y de si hablamos de pago, rectificación o revisión del dato.' },
      @{ q = '¿Es mejor pagar primero?'; a = 'Solo cuando el importe y la estrategia están claros. Si la deuda es dudosa, puede ser mejor aclararlo antes.' },
      @{ q = '¿Necesito abogado para todos los casos?'; a = 'No todos los supuestos exigen la misma intervención, pero sí conviene ordenar bien la documentación desde el inicio.' }
    )
    Related = @(
      @{ href = 'pages/salir-de-asnef.html'; label = 'Pilar principal para salir de ASNEF' },
      @{ href = 'articulos/cancelar-asnef-despues-de-pagar.html'; label = 'Qué hacer cuando ya has pagado' },
      @{ href = 'pages/contacto.html'; label = 'Consulta inicial sobre baja del fichero' }
    )
  },
  [ordered]@{
    Path = 'articulos/asnef-telefono-canales-oficiales.html'
    Title = 'ASNEF teléfono y canales oficiales: qué buscar y qué no esperar de una llamada'
    Description = 'Qué canales oficiales conviene revisar cuando buscas un teléfono de ASNEF y por qué muchas gestiones siguen necesitando referencia y documentación.'
    Eyebrow = 'Artículo SEO'
    Headline = 'Buscar un teléfono de ASNEF es normal, pero no todo se resuelve por voz.'
    Lead = 'Mucha gente llega a internet buscando ASNEF teléfono porque necesita una respuesta rápida. El problema es que esa búsqueda suele mezclarse con directorios de terceros, números sin contexto y expectativas poco realistas sobre lo que puede resolverse en una llamada.'
    Lead2 = 'Este artículo aclara algo importante: más que obsesionarte con un número, necesitas entender el canal correcto para cada gestión y preparar la documentación antes de contactar.'
    Category = 'Canales oficiales'
    ReadTime = '8 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Idea práctica'
    SideText = 'Una llamada puede orientar, pero la gestión útil suele exigir referencia, identificación y soporte documental.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué dice la información pública del fichero'; Paragraphs = @(
        'La propia información pública de ASNEF pone el foco en la plataforma de derechos y en las solicitudes formales para acceso, rectificación o cancelación. Eso ya te da una pista clara: no todo trámite relevante se resuelve por teléfono y muchas incidencias necesitan identificación y documentación verificable.',
        'Cuando buscas un teléfono, úsalo como punto de orientación y no como sustituto del expediente. Lo importante es saber qué canal deja rastro y qué referencia conviene tener preparada.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Qué preparar antes de contactar'; Paragraphs = @(
        'Lo más útil es reunir referencia de carta, documento de identidad, entidad informante, importe y un resumen muy breve del problema. Si llamas sin eso, es probable que la conversación sea demasiado genérica y no avance.',
        'También conviene distinguir si buscas información general, acceso a datos, revisión de una incidencia o simple confirmación de cómo presentar documentación. Son necesidades distintas.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Qué suele pedirse aunque exista atención telefónica'; Paragraphs = @('Incluso cuando hay atención o información por voz, el trabajo serio suele apoyarse en documentos.'); List = @(
        'Referencia de inclusión o del expediente.',
        'Documento identificativo.',
        'Justificantes si el asunto es un pago o una rectificación.',
        'Correo o escrito complementario para dejar constancia.'
      ) }
      @{ Id = 'errores'; Title = 'Qué no esperar de una llamada'; Paragraphs = @('Una llamada rara vez sustituye el ejercicio formal de derechos ni la acreditación documental.'); List = @(
        'Pensar que una llamada cancela el dato por sí sola.',
        'No anotar fecha, interlocutor y resumen de la conversación.',
        'Llamar a números de terceros sin verificar responsable.',
        'No dar seguimiento por escrito cuando hace falta.'
      ) }
    )
    NextTitle = 'Cómo usar bien el contacto telefónico'
    NextText = 'Utiliza la llamada para orientarte sobre canal y referencias, pero deja por escrito aquello que deba formar parte del expediente o del ejercicio de derechos.'
    Faqs = @(
      @{ q = '¿Existe un único teléfono que resuelva todas las gestiones?'; a = 'No es prudente plantearlo así. Lo relevante es confirmar el canal oficial aplicable y la documentación necesaria para cada trámite.' },
      @{ q = '¿Con una llamada puedo pedir la cancelación?'; a = 'Las gestiones importantes suelen requerir además soporte documental y, en su caso, ejercicio formal de derechos.' },
      @{ q = '¿Cómo evito teléfonos poco fiables?'; a = 'Comprueba siempre la información en las páginas oficiales y evita directorios o intermediarios que no identifiquen claramente al responsable.' }
    )
    Related = @(
      @{ href = 'pages/consultar-asnef.html'; label = 'Consulta de datos y referencias' },
      @{ href = 'pages/derechos-usuario.html'; label = 'Qué derechos puedes ejercer' },
      @{ href = 'pages/contacto.html'; label = 'Si necesitas ordenar primero el caso' }
    )
  },
  [ordered]@{
    Path = 'articulos/cancelar-asnef-despues-de-pagar.html'
    Title = 'Cancelar ASNEF después de pagar: cómo documentar la baja correctamente'
    Description = 'Qué hacer después de pagar una deuda incluida en ASNEF y cómo demostrar la regularización para facilitar la actualización del dato.'
    Eyebrow = 'Artículo SEO'
    Headline = 'Pagar ayuda, pero la baja necesita trazabilidad.'
    Lead = 'Muchas personas creen que, tras pagar, el asunto queda automáticamente resuelto. En la práctica, la cancelación o actualización del dato requiere que el expediente refleje esa regularización y que puedas acreditarla si surge cualquier retraso o discrepancia.'
    Lead2 = 'La mejor forma de protegerte es tratar el pago como una fase más del caso y no como el final invisible del problema.'
    Category = 'Cancelación ASNEF'
    ReadTime = '8 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Qué resuelve'
    SideText = 'Te ayuda a pasar del pago a la evidencia útil: justificantes, comunicaciones y seguimiento posterior.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué pago sirve de verdad como prueba'; Paragraphs = @(
        'La prueba útil es la que identifica claramente quién paga, a quién, cuánto, cuándo y por qué concepto. Una transferencia ambigua o una captura parcial puede ayudar, pero no siempre es suficiente si después aparece una discrepancia.',
        'Por eso conviene guardar justificantes completos y, cuando sea posible, solicitar confirmación escrita del acreedor sobre la regularización o el cierre del saldo.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Qué hacer justo después del pago'; Paragraphs = @(
        'No cierres la carpeta tras la transferencia. Anota fecha, importe, canal y cualquier correo recibido. Si el pago forma parte de un acuerdo, conserva el documento donde se vea el contexto completo.',
        'Después conviene revisar el expediente y comprobar que el dato evoluciona. Ese seguimiento evita quedarte sin margen cuando pasa el tiempo y ya cuesta reconstruir lo ocurrido.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Soporte mínimo que deberías conservar'; Paragraphs = @('Un pago bien documentado simplifica mucho la baja o la reclamación posterior.'); List = @(
        'Justificante íntegro del pago.',
        'Acuerdo previo o correo donde se fije la regularización.',
        'Identificación del acreedor y del expediente.',
        'Fecha en la que solicitaste o verificaste la actualización.'
      ) }
      @{ Id = 'errores'; Title = 'Errores frecuentes después del pago'; Paragraphs = @('El error más habitual es confiar en que todo se moverá solo y no guardar nada.'); List = @(
        'Eliminar justificantes porque el asunto parecía cerrado.',
        'No relacionar el pago con el expediente correcto.',
        'No pedir confirmación si existe incidencia previa.',
        'No revisar más adelante el estado del dato.'
      ) }
    )
    NextTitle = 'Qué deberías hacer al terminar de pagar'
    NextText = 'Guarda soporte completo, solicita confirmación si procede y vuelve a comprobar el estado del expediente dentro de una planificación razonable.'
    Faqs = @(
      @{ q = '¿Pagar implica cancelación automática?'; a = 'No conviene darlo por supuesto. El pago debe reflejarse y poder acreditarse correctamente.' },
      @{ q = '¿Sirve cualquier justificante?'; a = 'Cuanto más completo sea, mejor. Lo importante es que identifique emisor, destinatario, fecha, importe y concepto.' },
      @{ q = '¿Debo reclamar si tras pagar no cambia el dato?'; a = 'Si no ves evolución y tienes soporte claro, puede ser necesario activar seguimiento o revisión documental.' }
    )
    Related = @(
      @{ href = 'pages/salir-de-asnef.html'; label = 'Ruta completa para salir del fichero' },
      @{ href = 'articulos/salir-de-asnef-paso-a-paso.html'; label = 'Paso a paso para ordenar la salida' },
      @{ href = 'pages/contacto.html'; label = 'Revisar baja después del pago' }
    )
  },
  [ordered]@{
    Path = 'articulos/tiempo-en-asnef-cuanto-dura.html'
    Title = 'Tiempo en ASNEF: cuánto puede durar un dato y por qué el plazo no lo explica todo'
    Description = 'Cómo pensar el tiempo en ASNEF con criterio: permanencia del dato, seguimiento del expediente y relación con pagos o incidencias.'
    Eyebrow = 'Artículo SEO'
    Headline = 'El tiempo en ASNEF no se entiende solo mirando un calendario.'
    Lead = 'Una de las búsquedas más frecuentes es tiempo en ASNEF. Tiene lógica: quien sufre un bloqueo quiere saber cuándo terminará. Pero el plazo por sí solo no explica el caso. También importan el estado de la deuda, la trazabilidad documental y la forma en que se revisa o actualiza el expediente.'
    Lead2 = 'Este artículo no te vende un número mágico. Te ayuda a pensar en plazos de forma útil y a relacionarlos con el resto de piezas del caso.'
    Category = 'Plazos y seguimiento'
    ReadTime = '8 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Qué ordena'
    SideText = 'Aclara por qué el tiempo importa, pero siempre acompañado de estado real de deuda y documentación.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué significa hablar de tiempo en ASNEF'; Paragraphs = @(
        'Cuando la gente pregunta cuánto dura un dato, suele pensar en un reloj simple. Sin embargo, lo útil es distinguir entre inclusión, regularización, revisión y permanencia. Cada fase tiene su propia lógica y no todas dependen del mismo factor.',
        'Eso explica por qué dos personas con deudas parecidas pueden vivir recorridos muy distintos: una porque pagó y acreditó bien, otra porque discutió el dato, otra porque ni siquiera sabe desde qué fecha exacta corre la incidencia.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo usar el plazo de forma práctica'; Paragraphs = @(
        'El plazo solo ayuda si se integra en una cronología del caso. Saber cuándo empezó el problema, cuándo se consultó, si hubo pago y qué respuesta se recibió permite convertir el tiempo en una herramienta de seguimiento y no en una fuente más de ansiedad.',
        'Por eso conviene anotar fechas clave y no confiar en recuerdos aproximados. Cuando llega el momento de reclamar o acreditar algo, esa cronología pesa mucho.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Fechas que conviene tener controladas'; Paragraphs = @('Un expediente bien ordenado debería incluir al menos estas referencias temporales.'); List = @(
        'Fecha aproximada del vencimiento o del impago.',
        'Fecha de inclusión o de la carta recibida.',
        'Fecha de pago, si la hubo.',
        'Fechas de consultas, reclamaciones o respuestas.'
      ) }
      @{ Id = 'errores'; Title = 'Errores al hablar de plazos'; Paragraphs = @('La simplificación excesiva suele ser la principal fuente de errores.'); List = @(
        'Reducir todo a un número sin mirar el expediente.',
        'No guardar la prueba de las fechas relevantes.',
        'Confundir actualización del dato con desaparición inmediata.',
        'Pensar que esperar pasivamente siempre ayuda.'
      ) }
    )
    NextTitle = 'Cómo convertir el tiempo en una ventaja'
    NextText = 'Haz una línea temporal del caso y úsala para comprobar avances, reclamar con criterio o detectar que el expediente se está moviendo peor de lo que debería.'
    Faqs = @(
      @{ q = '¿Hay un plazo único que resuelva cualquier caso?'; a = 'No conviene simplificarlo así. El seguimiento útil depende también del estado documental y de la evolución real de la deuda.' },
      @{ q = '¿Esperar sin hacer nada puede resolverlo?'; a = 'A veces la espera ordenada tiene sentido, pero no debería sustituir la revisión del expediente y de la documentación disponible.' },
      @{ q = '¿Debo guardar fechas aunque el caso parezca claro?'; a = 'Sí. Las fechas son clave para orientar reclamaciones, pagos y seguimientos posteriores.' }
    )
    Related = @(
      @{ href = 'pages/prescripcion-deudas.html'; label = 'Plazos y cronología de deuda' },
      @{ href = 'pages/salir-de-asnef.html'; label = 'Qué hacer mientras sigues el expediente' },
      @{ href = 'pages/contacto.html'; label = 'Revisar fechas y documentación' }
    )
  },
  [ordered]@{
    Path = 'articulos/asnef-gratis-consulta-opciones-reales.html'
    Title = 'ASNEF gratis: opciones reales para consultar y ordenar el expediente'
    Description = 'Qué significa realmente una consulta gratis de ASNEF y cómo evitar intermediarios poco transparentes.'
    Eyebrow = 'Artículo SEO'
    Headline = 'La consulta gratuita solo sirve si el canal también es fiable.'
    Lead = 'Quien busca asnef gratis consulta normalmente quiere confirmar el dato sin pagar a un intermediario. Esa intención es razonable. El problema aparece cuando la urgencia lleva a entregar documentación a servicios opacos o a confundir información general con gestión útil.'
    Lead2 = 'Este artículo explica qué puede entenderse por consulta gratuita, cuándo tiene sentido y qué señales deben hacerte desconfiar de ciertas promesas comerciales.'
    Category = 'Consulta gratuita'
    ReadTime = '8 min de lectura'
    Published = '2026-04-01'
    SideTitle = 'Qué aclara'
    SideText = 'Que una consulta no tenga coste no significa que cualquier canal sea adecuado ni que resuelva todo el expediente.'
    BodyClass = 'theme-home page-article'
    Sections = @(
      @{ Id = 'revisar'; Title = 'Qué es una consulta útil'; Paragraphs = @(
        'La consulta valiosa es la que confirma la existencia del dato, identifica la entidad informante y te deja material para actuar después. Si el canal es confuso, no identifica responsable o pide datos excesivos sin explicar finalidad, deja de ser una ayuda y empieza a ser un riesgo.',
        'En la práctica, lo más sensato es apoyar la consulta en canales oficiales o claramente verificables y usar los servicios de terceros solo cuando expliquen muy bien quién trata tus datos y para qué.'
      ); List = @() }
      @{ Id = 'actuar'; Title = 'Cómo reconocer intermediación poco clara'; Paragraphs = @(
        'Hay mensajes que prometen consulta inmediata, borrado rápido o “salida garantizada” en el mismo paquete. Ese tipo de mezcla suele ser una señal de alerta. La consulta no equivale a la cancelación y la gestión seria de un expediente rara vez cabe en una promesa genérica.',
        'Si el servicio no explica su responsable, su política de privacidad o su papel exacto, es mejor no seguir por ahí.'
      ); List = @() }
      @{ Id = 'documentacion'; Title = 'Qué deberías preparar incluso en una consulta gratuita'; Paragraphs = @('La gratuidad no elimina la necesidad de orden documental.'); List = @(
        'Documento identificativo.',
        'Referencia de carta si existe.',
        'Resumen del problema y de la deuda asociada.',
        'Canal por el que conservarás la respuesta.'
      ) }
      @{ Id = 'errores'; Title = 'Errores comunes'; Paragraphs = @('El error habitual es confundir ahorro con falta de criterio.'); List = @(
        'Entregar datos a servicios opacos por simple urgencia.',
        'No guardar la respuesta obtenida.',
        'Pensar que la consulta gratuita ya resuelve el caso.',
        'Aceptar mensajes de salida garantizada sin revisar condiciones.'
      ) }
    )
    NextTitle = 'Cómo consultar gratis sin perder control'
    NextText = 'Empieza por canales verificables, guarda la respuesta y úsala para ordenar deuda, derechos y siguientes pasos. Esa es la parte que realmente aporta valor.'
    Faqs = @(
      @{ q = '¿Consultar gratis es lo mismo que reclamar gratis?'; a = 'No. La consulta confirma información; la reclamación o la baja exigen trabajo adicional y documentación.' },
      @{ q = '¿Todo servicio gratuito es fiable?'; a = 'No. La fiabilidad depende de la transparencia del responsable y del tratamiento de tus datos.' },
      @{ q = '¿Puedo consultar sin la carta de inclusión?'; a = 'Sí, aunque la referencia ayuda mucho. Si no la tienes, necesitarás ordenar mejor el resto del expediente.' }
    )
    Related = @(
      @{ href = 'pages/consultar-asnef.html'; label = 'Categoría principal de consulta' },
      @{ href = 'articulos/como-comprobar-fichero-solvencia.html'; label = 'Cómo comprobar tu inclusión con método' },
      @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas ordenar el caso' }
    )
  }
)

$generatedArticlePages += @(
  (New-TopicArticle -Path 'articulos/negociar-deuda-antes-de-firmar.html' -Title 'Negociar una deuda antes de firmar: qué revisar para no empeorar la posición' -Description 'Cómo preparar una negociación de deuda, qué condiciones leer y qué compromisos conviene dejar por escrito.' -Category 'Negociación de deuda' -Eyebrow 'Artículo SEO' -Headline 'Negociar bien empieza antes de aceptar la primera propuesta.' -Lead 'Cuando la presión aprieta, cualquier propuesta puede parecer una salida. Pero una negociación mal entendida puede dejarte con un pago difícil de sostener, un reconocimiento de deuda poco claro o la sensación de haber firmado algo que no controlabas del todo.' -Lead2 'Este artículo te ayuda a mirar una negociación con cabeza fría: qué revisar, qué pedir por escrito y cómo evitar acuerdos que solucionan la urgencia de hoy y empeoran la posición de mañana.' -SideTitle 'Qué aclara' -SideText 'Que negociar no es solo conseguir una rebaja; también es entender alcance, plazo, prueba y consecuencias.' -ReviewPoint 'Antes de aceptar nada, conviene saber si la propuesta se limita a aplazar pagos, si modifica importes, si exige renuncias o si incorpora condiciones que luego puedan afectar a una eventual cancelación del dato.' -ContextPoint 'En muchas negociaciones de consumo o telefonía, el problema no es solo el dinero pendiente, sino cómo queda redactado el compromiso y qué ocurre si después quieres acreditar pago, discutir un servicio o pedir la actualización de la información comunicada.' -ActionPoint 'La mejor negociación suele empezar con dos preguntas sencillas: qué estoy reconociendo exactamente y qué recibiré a cambio si cumplo. Si no puedes responderlas con documentos delante, todavía no estás en una buena posición para cerrar nada.' -DecisionPoint 'También conviene separar urgencia de estrategia. Un acuerdo puede ser razonable si encaja con tu capacidad real y queda bien documentado; en cambio, aceptar cuotas inviables o cláusulas confusas solo desplaza el problema unas semanas.' -DocsIntro 'Para revisar una negociación con criterio, interesa reunir la propuesta completa y cualquier documento que permita compararla con la situación previa.' -DocumentList @('Oferta o propuesta enviada por la entidad o el gestor.', 'Contrato o factura que dio origen a la deuda.', 'Detalle de cuotas, vencimientos y posibles intereses.', 'Correos o mensajes donde se expliquen condiciones y efectos del acuerdo.') -MistakeIntro 'El error habitual es negociar mirando solo la cuota mensual y no el conjunto del compromiso.' -MistakeList @('Aceptar plazos que no encajan con tu liquidez real.', 'Firmar sin pedir confirmación escrita de importes y calendario.', 'Confiar en promesas verbales sobre la baja del fichero.', 'No guardar copia íntegra del acuerdo final.') -NextTitle 'Qué hacer antes de firmar' -NextText 'Lee la propuesta completa, confirma importe y calendario y comprueba si el acuerdo mejora de verdad tu posición o solo aplaza una incidencia mal explicada.' -Faqs @(@{ q = '¿Negociar siempre implica reconocer toda la deuda?'; a = 'No necesariamente. Depende del contenido del acuerdo. Precisamente por eso es importante revisar qué estás aceptando y con qué alcance.' }, @{ q = '¿Conviene cerrar por teléfono si me ofrecen una rebaja?'; a = 'Solo como paso inicial. Lo relevante debe quedar por escrito antes de considerar la negociación cerrada.' }, @{ q = '¿Un acuerdo garantiza salir de ASNEF?'; a = 'No por sí solo. Debe revisarse cómo se documenta el cumplimiento y cómo se actualizará la información del expediente.' }) -Related @(@{ href = 'pages/negociar-deudas.html'; label = 'Guía sobre negociación de deudas' }, @{ href = 'articulos/cancelar-asnef-despues-de-pagar.html'; label = 'Qué hacer después de regularizar la deuda' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si quieres revisar una propuesta' }) -ReadTime '10 min de lectura'),
  (New-TopicArticle -Path 'articulos/prescripcion-y-cronologia.html' -Title 'Prescripción y cronología de deuda: por qué las fechas importan más de lo que parece' -Description 'Cómo ordenar la cronología de una deuda y por qué hablar de prescripción sin fechas claras suele llevar a errores.' -Category 'Prescripción de deudas' -Eyebrow 'Artículo SEO' -Headline 'La prescripción no se entiende sin una cronología bien hecha.' -Lead 'Muchas personas oyen que una deuda “puede prescribir” y convierten esa idea en una respuesta automática. El problema es que la palabra prescripción sirve de poco si no has ordenado primero las fechas que realmente sostienen o debilitan tu caso.' -Lead2 'Aquí no vas a encontrar una promesa rápida, sino un método para trabajar la cronología: vencimiento, comunicaciones, reclamaciones, pagos parciales y cualquier hecho que altere la lectura del expediente.' -SideTitle 'Qué resuelve' -SideText 'Te ayuda a dejar de pensar en abstracto y a mirar el tiempo del caso con referencias concretas.' -ReviewPoint 'Lo primero es ubicar el momento en que nace el problema económico y distinguir esa fecha de otras posteriores, como cartas de cobro, llamadas, refinanciaciones o reclamaciones dirigidas al consumidor.' -ContextPoint 'En expedientes de deuda, una sola fecha rara vez explica todo. Lo que de verdad ayuda es la secuencia: cuándo surgió la obligación, qué pasó después y qué hechos interrumpieron o cambiaron el escenario.' -ActionPoint 'Si sospechas que el tiempo puede ser relevante, trabaja con una tabla simple y no con recuerdos dispersos. Anota origen, importe, fecha, quién comunica cada cosa y si existe soporte documental. Esa base permite orientar mejor cualquier consulta posterior.' -DecisionPoint 'También conviene evitar un salto frecuente: pasar de una intuición sobre el tiempo transcurrido a una conclusión cerrada sobre la situación jurídica. Entre una cosa y otra suele faltar documentación, matiz y lectura del caso concreto.' -DocsIntro 'La cronología útil mezcla documentos de origen con pruebas de lo que ha ido ocurriendo después.' -DocumentList @('Contrato, factura o documento que origine la obligación.', 'Cartas o correos de reclamación recibidos con fecha.', 'Justificantes de pagos parciales, aplazamientos o acuerdos.', 'Anotaciones propias con fechas de contactos y respuestas.') -MistakeIntro 'El error más repetido consiste en hablar de prescripción sin haber reconstruido antes la historia del expediente.' -MistakeList @('Confundir fecha de impago con fecha de inclusión o con fecha de reclamación.', 'Olvidar pagos o acuerdos que cambian la lectura temporal.', 'Confiar en cálculos aproximados sin revisar documentos.', 'Usar una cifra general como si resolviera cualquier caso.') -NextTitle 'Cómo ordenar la cronología hoy mismo' -NextText 'Empieza por una hoja con cuatro columnas: fecha, hecho, documento y consecuencia. Esa visión limpia suele aclarar más que muchas llamadas improvisadas.' -Faqs @(@{ q = '¿La antigüedad de una deuda basta para sacar conclusiones?'; a = 'No. La antigüedad orienta, pero sin cronología y soporte documental puede llevar a errores importantes.' }, @{ q = '¿Un pago parcial afecta a la lectura del tiempo?'; a = 'Puede afectar al expediente y a cómo se interpreta la evolución del caso, por eso conviene registrarlo bien.' }, @{ q = '¿Tiene sentido revisar fechas aunque crea que la deuda es pequeña?'; a = 'Sí. Las fechas importan tanto en deudas grandes como en incidencias de importe reducido.' }) -Related @(@{ href = 'pages/prescripcion-deudas.html'; label = 'Guía principal sobre prescripción' }, @{ href = 'articulos/tiempo-en-asnef-cuanto-dura.html'; label = 'Cómo pensar los plazos en ASNEF' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas ordenar fechas y documentos' }) -ReadTime '11 min de lectura'),
  (New-TopicArticle -Path 'articulos/que-implica-aparecer-en-asnef.html' -Title 'Qué implica aparecer en ASNEF: efectos reales y errores de interpretación comunes' -Description 'Qué consecuencias prácticas suele tener aparecer en ASNEF y por qué conviene mirar el expediente completo antes de precipitarse.' -Category 'ASNEF' -Eyebrow 'Artículo SEO' -Headline 'Aparecer en ASNEF afecta, pero no siempre de la misma manera.' -Lead 'La reacción inmediata suele ser imaginar un bloqueo total de la vida financiera. Esa idea mezcla una parte real con bastante ruido. Estar en ASNEF puede complicar operaciones y generar fricción, pero entender bien el efecto concreto del dato ayuda mucho más que moverse solo por el miedo.' -Lead2 'Este artículo baja el problema a tierra: qué efectos son habituales, qué depende del tipo de operación y por qué la mejor respuesta sigue siendo revisar el expediente con detalle antes de decidir.' -SideTitle 'Qué pone en contexto' -SideText 'Que el impacto existe, pero debe leerse junto con importe, antigüedad, sector y objetivo que tengas delante.' -ReviewPoint 'Lo primero es identificar en qué momento estás notando el impacto: crédito personal, financiación de consumo, telefonía, alquiler, renegociación bancaria o simple inquietud preventiva. La consecuencia práctica no siempre es la misma.' -ContextPoint 'En algunos casos el dato se traduce en una denegación directa; en otros, en más preguntas, peores condiciones o exigencia de garantías adicionales. Por eso conviene salir de la idea genérica de “estar marcado” y mirar el contexto real.' -ActionPoint 'La forma más útil de actuar es convertir la preocupación en preguntas comprobables: qué entidad informó, qué importe figura, desde cuándo y para qué operación concreta estás notando el efecto. Esa precisión te coloca mucho mejor para decidir si corresponde pagar, reclamar, negociar o simplemente ordenar la situación.' -DecisionPoint 'También ayuda distinguir consecuencias inmediatas de consecuencias estructurales. A veces el problema urgente es una financiación que no sale; otras, la necesidad de entender si el dato es correcto antes de iniciar cualquier regularización.' -DocsIntro 'Para entender el impacto real del dato, conviene reunir tanto la información del expediente como la de la operación que se ha visto afectada.' -DocumentList @('Referencia o comunicación relacionada con la inclusión.', 'Solicitud de financiación, alta de servicio o contratación afectada.', 'Mensajes de denegación o peticiones de documentación adicional.', 'Resumen de deudas o incidencias que puedan estar vinculadas.') -MistakeIntro 'El error frecuente es tratar ASNEF como una explicación única para todo lo que sale mal en tu economía.' -MistakeList @('No verificar si la operación fallida realmente se relaciona con el dato.', 'Dar por hecho que cualquier acreedor o proveedor reaccionará igual.', 'Pagar deprisa sin entender si el expediente es correcto.', 'No guardar prueba de la incidencia que activó la preocupación.') -NextTitle 'Cómo rebajar incertidumbre' -NextText 'En lugar de pensar solo en consecuencias genéricas, identifica el efecto concreto que estás sufriendo y conecta ese problema con la documentación del expediente.' -Faqs @(@{ q = '¿Estar en ASNEF impide cualquier financiación?'; a = 'No siempre. Puede dificultarla mucho, pero cada entidad valora riesgo y contexto de forma distinta.' }, @{ q = '¿El impacto es igual en bancos y servicios de telefonía?'; a = 'No necesariamente. El sector y el tipo de operación influyen en la reacción práctica.' }, @{ q = '¿Conviene revisar el expediente aunque ya sepa que me denegaron algo?'; a = 'Sí. Entender la causa exacta ayuda a decidir el siguiente paso con más criterio.' }) -Related @(@{ href = 'pages/asnef.html'; label = 'Guía general sobre ASNEF' }, @{ href = 'pages/salir-de-asnef.html'; label = 'Qué hacer si tu prioridad es salir del fichero' }, @{ href = 'articulos/como-comprobar-fichero-solvencia.html'; label = 'Cómo comprobar el dato con método' }) -ReadTime '10 min de lectura'),
  (New-TopicArticle -Path 'articulos/como-saber-si-estoy-en-asnef.html' -Title 'Cómo saber si estoy en ASNEF: señales, pasos de comprobación y documentos útiles' -Description 'Método claro para comprobar si estás en ASNEF, qué señales orientan y cómo convertir una sospecha en información verificable.' -Category 'Cómo saber si estoy en ASNEF' -Eyebrow 'Artículo SEO' -Headline 'La duda se resuelve mejor con método que con intuición.' -Lead '“Cómo saber si estoy en ASNEF” es una de las búsquedas más repetidas porque mucha gente llega a ella después de una denegación, una llamada de cobro o un bloqueo que no entiende. El problema es que la sospecha por sí sola no permite decidir bien.' -Lead2 'Lo útil es transformar esa intuición en una verificación ordenada: revisar señales, confirmar referencia, guardar respuesta y usarla como base para actuar después.' -SideTitle 'Qué ordena' -SideText 'Te ayuda a pasar de la sospecha difusa a una comprobación útil para reclamar, pagar o seguir investigando.' -ReviewPoint 'Las señales más comunes suelen ser una negativa a financiar, comunicaciones de acreedores, cartas relacionadas con inclusión o respuestas ambiguas en procesos de contratación. Ninguna de ellas basta por sí sola, pero todas sirven para orientar la revisión inicial.' -ContextPoint 'En el mercado español, muchas personas llegan a esta situación con información fragmentada: recuerdan una deuda antigua, dudan del importe o no saben si el problema viene del fichero o de otra política interna de la entidad consultada.' -ActionPoint 'Empieza por recoger cualquier carta, correo o mensaje que mencione deuda, incidencia o solvencia. Si tienes una referencia, úsala. Si no, prepara identificación y una descripción breve del problema. El objetivo es obtener confirmación y no perder la trazabilidad del proceso.' -DecisionPoint 'Una vez confirmada la inclusión, la pregunta ya no es si estás o no, sino qué tipo de expediente tienes delante. Esa diferencia cambia por completo el siguiente paso: revisar deuda, reclamar, acreditar pago o ajustar expectativas sobre plazos.' -DocsIntro 'La sospecha se convierte en expediente cuando logras apoyarla en documentos mínimos y ordenados.' -DocumentList @('Carta de inclusión o comunicación relacionada con solvencia.', 'Documento identificativo.', 'Mensajes de denegación o incidencias de contratación.', 'Resumen de deudas pendientes o discutidas.') -MistakeIntro 'El error más común es consultar de forma impulsiva y no guardar nada de lo obtenido.' -MistakeList @('Confiar solo en lo que te dijeron por teléfono.', 'No registrar fecha y canal de la consulta.', 'Mezclar varias incidencias sin separarlas por acreedor.', 'Pensar que confirmar la inclusión ya resuelve el problema.') -NextTitle 'Cómo salir de la duda con poco esfuerzo' -NextText 'Reúne las señales que ya tienes, confirma la inclusión por un canal verificable y guarda todo como si después fueras a tener que explicarlo a un tercero.' -Faqs @(@{ q = '¿Una financiación denegada significa que estoy en ASNEF?'; a = 'No necesariamente. Puede ser una pista, pero necesitas confirmación documental o una consulta verificable.' }, @{ q = '¿Debo esperar a recibir carta para comprobarlo?'; a = 'No. Si tienes indicios razonables, puedes empezar a ordenar el caso y revisar los canales disponibles.' }, @{ q = '¿Conviene guardar capturas y correos desde el principio?'; a = 'Sí. La trazabilidad ayuda tanto para reclamar como para explicar la situación después.' }) -Related @(@{ href = 'pages/consultar-asnef.html'; label = 'Categoría principal de consulta' }, @{ href = 'articulos/como-comprobar-fichero-solvencia.html'; label = 'Método completo para comprobar la inclusión' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si quieres revisar tu caso' }) -ReadTime '10 min de lectura')
)

$generatedArticlePages += @(
  (New-TopicArticle -Path 'articulos/consultar-asnef-con-dni.html' -Title 'Consultar ASNEF con DNI: qué preparar, qué esperar y cómo guardar la respuesta' -Description 'Qué significa consultar ASNEF con DNI, qué documentos ayudan y cómo conservar una respuesta útil para el expediente.' -Category 'Consultar ASNEF con DNI' -Eyebrow 'Artículo SEO' -Headline 'El DNI ayuda, pero no sustituye una consulta bien planteada.' -Lead 'Muchas búsquedas se formulan como “consultar ASNEF con DNI” porque parece la vía más simple para salir de dudas. Y en parte lo es: la identificación es básica. Lo que no conviene es pensar que con solo aportar el documento ya quedará todo resuelto.' -Lead2 'Lo importante no es solo identificarte, sino preparar la consulta para que la respuesta sirva después como prueba de trabajo y no como un dato suelto difícil de reutilizar.' -SideTitle 'Qué aterriza' -SideText 'Que la identificación es necesaria, pero lo valioso es la calidad de la consulta y la conservación de la respuesta.' -ReviewPoint 'Conviene revisar si además del DNI tienes referencia de carta, datos del acreedor, fecha aproximada de la incidencia o cualquier comunicación que conecte la consulta con un expediente concreto.' -ContextPoint 'Cuando falta contexto, la persona recibe información pero no siempre sabe interpretarla. Eso genera una segunda ronda de llamadas o mensajes que podrían haberse evitado preparando mejor la consulta desde el principio.' -ActionPoint 'Si vas a consultar, hazlo con una finalidad clara: confirmar inclusión, identificar entidad informante o preparar una eventual reclamación. Esa intención te ayuda a decidir qué datos llevar y qué elementos de la respuesta necesitas conservar.' -DecisionPoint 'Después de recibir la información, dedica unos minutos a clasificarla. Guarda el canal utilizado, la fecha, el contenido relevante y cualquier número de referencia. Esa rutina convierte una simple consulta en una base útil para los pasos siguientes.' -DocsIntro 'Además del documento identificativo, hay piezas que mejoran mucho la calidad de la consulta.' -DocumentList @('DNI o documento equivalente.', 'Carta o referencia previa si la tienes.', 'Nombre de la entidad o servicio relacionado con la deuda.', 'Resumen breve del motivo por el que consultas ahora.') -MistakeIntro 'El problema no suele ser consultar con DNI, sino creer que eso basta para cerrar el asunto.' -MistakeList @('No guardar copia de la respuesta recibida.', 'Consultar sin saber qué información buscas exactamente.', 'Olvidar relacionar la respuesta con una deuda concreta.', 'Repetir la consulta por varios canales sin orden documental.') -NextTitle 'Cómo hacer útil la consulta' -NextText 'Identifícate, pide o guarda la referencia y archiva la respuesta junto con el resto del expediente. Ese orden vale más que consultar diez veces.' -Faqs @(@{ q = '¿El DNI es suficiente en todos los casos?'; a = 'Es una pieza básica, pero a menudo conviene acompañarlo de referencia, contexto y documentación adicional.' }, @{ q = '¿La consulta con DNI ya sirve como reclamación?'; a = 'No. Confirmar información y reclamar son gestiones distintas, aunque una pueda preparar la otra.' }, @{ q = '¿Qué hago si recibo una respuesta muy genérica?'; a = 'Guárdala igual y ordénala con el resto del caso. Puede orientarte sobre el siguiente canal o documento que necesitas.' }) -Related @(@{ href = 'pages/consultar-asnef.html'; label = 'Guía principal de consulta' }, @{ href = 'articulos/asnef-gratis-consulta-opciones-reales.html'; label = 'Opciones reales para consultar gratis' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas interpretar la respuesta' }) -ReadTime '10 min de lectura'),
  (New-TopicArticle -Path 'articulos/asnef-telefonia-reclamar-facturas.html' -Title 'ASNEF y telefonía: cómo reclamar facturas discutidas sin perder el hilo documental' -Description 'Qué revisar cuando la incidencia viene de telefonía, cómo reclamar una factura discutida y qué prueba conviene guardar.' -Category 'ASNEF y telefonía' -Eyebrow 'Artículo SEO' -Headline 'Las deudas de telefonía exigen mucho orden porque el conflicto suele venir de detalle.' -Lead 'Las incidencias de telefonía son uno de los escenarios más confusos: altas, bajas, permanencias, penalizaciones, terminales, duplicidades o cargos posteriores que el cliente no esperaba. Cuando eso termina conectado con ASNEF, la sensación de desorden crece rápido.' -Lead2 'La clave suele estar en bajar el conflicto a hechos concretos y no discutir “el caso entero” en bloque. Factura, fecha, servicio, baja, consumo o cargo deben analizarse por separado para construir una reclamación útil.' -SideTitle 'Qué pone en foco' -SideText 'Que en telefonía el matiz contractual y la cronología de gestiones pesan muchísimo.' -ReviewPoint 'Antes de discutir el fichero, conviene revisar el origen exacto de la factura o penalización: contrato, permanencia, solicitud de baja, devolución de equipos o supuestos consumos que no encajan con tu uso real.' -ContextPoint 'En este tipo de conflictos, muchas personas mezclan una mala experiencia comercial con una deuda concreta. Separar ambas cosas ayuda: una cosa es el descontento con la compañía y otra el dato económico exacto que después puede usarse en un expediente de solvencia.' -ActionPoint 'Empieza reuniendo contrato, últimas facturas, prueba de baja o portabilidad y cualquier reclamación previa. Si el problema está en un cargo muy concreto, no lo diluyas hablando de todo el historial. Cuanto más definida esté la incidencia, mejor funciona la reclamación.' -DecisionPoint 'Si además aparece ASNEF, tendrás que decidir si la prioridad es discutir la validez del cargo, reclamar la inclusión o ambas cosas en paralelo. El orden depende de la prueba disponible y de cómo afecta el caso a tus necesidades actuales.' -DocsIntro 'En telefonía, la calidad del expediente depende mucho de conservar trazas comerciales y técnicas.' -DocumentList @('Contrato y condiciones de permanencia si existían.', 'Factura o penalización discutida.', 'Prueba de baja, portabilidad o devolución de equipos.', 'Números de incidencia, correos y capturas del área de cliente.') -MistakeIntro 'El error clásico es discutirlo todo al mismo tiempo y sin delimitar qué factura o cargo está en juego.' -MistakeList @('No guardar número de incidencia de cada reclamación.', 'Confundir una mala atención con la discusión del cargo concreto.', 'No conservar prueba de baja o devolución del router o equipo.', 'Pagar o aceptar acuerdos sin entender qué factura cierran realmente.') -NextTitle 'Cómo ordenar un caso de telefonía' -NextText 'Aísla el cargo discutido, reúne contrato y baja y construye una cronología breve. Ese paso aclara mucho antes de llamar o reclamar.' -Faqs @(@{ q = '¿Una factura de telefonía puede terminar en ASNEF?'; a = 'Sí, puede ocurrir en determinados escenarios, por eso conviene revisar el origen exacto del cargo cuanto antes.' }, @{ q = '¿Sirve reclamar verbalmente a la operadora?'; a = 'Puede servir como primer paso, pero lo prudente es dejar rastro documental de la reclamación.' }, @{ q = '¿Debo centrarme primero en la factura o en ASNEF?'; a = 'Depende del caso, pero suele ser clave entender primero el cargo discutido y la prueba que tienes para sostener tu versión.' }) -Related @(@{ href = 'articulos/reclamar-inclusion-indebida-asnef.html'; label = 'Cómo reclamar una inclusión indebida' }, @{ href = 'articulos/asnef-telefono-canales-oficiales.html'; label = 'Canales y teléfono: qué esperar realmente' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial para ordenar una incidencia de telefonía' }) -ReadTime '11 min de lectura'),
  (New-TopicArticle -Path 'articulos/baja-asnef-por-error-documentos-clave.html' -Title 'Baja de ASNEF por error: documentos clave para sostener una rectificación' -Description 'Qué documentos ayudan cuando buscas la baja de ASNEF por error y cómo preparar un expediente más sólido.' -Category 'Baja de ASNEF por error' -Eyebrow 'Artículo SEO' -Headline 'Los errores se corrigen mejor cuando la prueba es simple y muy legible.' -Lead 'Buscar la baja de ASNEF por error suele venir acompañado de mucha frustración. La persona sabe que algo no encaja, pero a menudo no tiene claro cómo demostrarlo. El punto de giro casi siempre es el mismo: dejar de explicarlo solo con palabras y apoyarlo en documentos ordenados.' -Lead2 'Esta guía se centra en eso: qué piezas documentales suelen ayudar más, cómo presentarlas y por qué una reclamación breve y bien montada suele ser más eficaz que una carpeta enorme sin estructura.' -SideTitle 'Qué mejora' -SideText 'Te ayuda a transformar una intuición de error en una reclamación más defendible.' -ReviewPoint 'Lo primero es identificar dónde está exactamente el error: deuda ya pagada, importe incorrecto, persona equivocada, contrato no reconocido, servicio mal facturado o incidencia que sigue abierta pese a existir contestación previa.' -ContextPoint 'Sin esa delimitación, muchas reclamaciones se quedan en mensajes genéricos del tipo “eso está mal” y pierden fuerza. En cambio, cuando el error queda vinculado a un documento concreto, el caso se vuelve mucho más manejable.' -ActionPoint 'La estrategia útil suele consistir en recortar el expediente a lo esencial y construir una secuencia clara: qué dato aparece, por qué lo consideras incorrecto y qué prueba lo respalda. No hace falta adornar demasiado si la evidencia principal está bien elegida.' -DecisionPoint 'Si el error afecta a una financiación urgente o a un bloqueo importante, puede ser tentador llamar a varios sitios a la vez. Aun así, conviene preservar un núcleo documental estable para que cualquier gestión posterior parta siempre de la misma base.' -DocsIntro 'Los documentos más útiles no son los más numerosos, sino los que conectan de forma directa tu versión con un hecho comprobable.' -DocumentList @('Justificante de pago o regularización si existe.', 'Contrato, factura o documento de origen de la incidencia.', 'Comunicaciones previas donde conste la discusión del dato.', 'Respuesta de la entidad o cualquier referencia de expediente.') -MistakeIntro 'El error más costoso es reclamar sin identificar con precisión cuál es el dato incorrecto.' -MistakeList @('Enviar documentos sin explicar qué prueban.', 'Cambiar de relato en cada canal de contacto.', 'No conservar acuse, referencia o prueba de envío.', 'Confiar solo en llamadas cuando el caso requiere soporte escrito.') -NextTitle 'Cómo preparar una rectificación defendible' -NextText 'Resume el error en una frase, escoge dos o tres documentos que lo prueben y construye una cronología mínima. Eso suele dar más claridad que cualquier discurso largo.' -Faqs @(@{ q = '¿Necesito muchos documentos para reclamar un error?'; a = 'No. Normalmente ayudan más pocos documentos bien escogidos y explicados que un volumen grande sin orden.' }, @{ q = '¿Qué pasa si tengo pruebas parciales?'; a = 'Pueden servir para abrir la revisión, siempre que expliques con claridad qué acreditan y qué falta por comprobar.' }, @{ q = '¿Llamar es suficiente cuando hay un error claro?'; a = 'Puede orientar, pero la rectificación seria suele necesitar rastro documental.' }) -Related @(@{ href = 'pages/reclamar-asnef.html'; label = 'Guía principal sobre reclamaciones' }, @{ href = 'articulos/reclamar-inclusion-indebida-asnef.html'; label = 'Reclamar una inclusión indebida paso a paso' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas ordenar la prueba' }) -ReadTime '10 min de lectura'),
  (New-TopicArticle -Path 'articulos/asnef-y-prestamos-que-mirar-antes-de-pedir-financiacion.html' -Title 'ASNEF y préstamos: qué mirar antes de pedir financiación con una incidencia abierta' -Description 'Qué revisar si necesitas un préstamo y existe una incidencia relacionada con ASNEF, para no empeorar la situación.' -Category 'ASNEF y préstamos' -Eyebrow 'Artículo SEO' -Headline 'Pedir financiación con una incidencia abierta exige más preparación que urgencia.' -Lead 'Cuando hace falta liquidez, la tentación es buscar un préstamo cuanto antes y ya. Si además sospechas o sabes que existe una incidencia en ASNEF, ese impulso puede conducirte a solicitudes precipitadas, comparadores poco transparentes o productos que empeoran tu situación.' -Lead2 'El foco de este artículo está en prepararte antes de pedir: qué mirar, qué expectativas ajustar y cuándo puede tener más sentido ordenar el expediente primero que seguir acumulando intentos.' -SideTitle 'Qué aterriza' -SideText 'Que la necesidad de financiación no debería hacerte renunciar a revisar riesgo, coste y viabilidad real.' -ReviewPoint 'Conviene revisar tu objetivo económico concreto: si buscas cubrir una urgencia inmediata, refinanciar otra deuda o ganar tiempo. Esa diferencia cambia mucho la lectura del riesgo y la utilidad real del préstamo.' -ContextPoint 'En escenarios con ASNEF, algunas entidades endurecen condiciones, otras deniegan y otras trasladan el coste al precio o a garantías adicionales. Por eso no basta con preguntar “si me lo darán”, sino también “en qué términos y con qué consecuencias”.' -ActionPoint 'Antes de solicitar, ordena tus ingresos, gastos, deudas y documentación básica del expediente. Si el dato en ASNEF es discutido o ya regularizaste la deuda, quizá tenga más sentido avanzar por esa vía antes de abrir nuevas solicitudes que solo generen más desgaste.' -DecisionPoint 'La decisión prudente no siempre es dejar de pedir financiación, pero sí evitar que la urgencia te lleve a aceptar importes, plazos o canales poco transparentes. Cuando el margen económico es estrecho, el coste del error es mucho mayor.' -DocsIntro 'Tener preparada la información financiera básica y el expediente de solvencia te ayuda a evaluar mejor cualquier alternativa.' -DocumentList @('Resumen actualizado de ingresos y gastos fijos.', 'Detalle de otras deudas o cuotas activas.', 'Información disponible sobre la incidencia en ASNEF.', 'Oferta o condiciones del préstamo que estás valorando.') -MistakeIntro 'El error típico es pedir por impulso y revisar condiciones cuando ya estás casi comprometido.' -MistakeList @('Solicitar a ciegas sin entender el coste total.', 'No valorar si ordenar ASNEF primero mejoraría el escenario.', 'Aceptar intermediarios poco transparentes por simple urgencia.', 'Perder de vista que una cuota baja puede ocultar un plazo muy largo.') -NextTitle 'Qué revisar antes de solicitar nada' -NextText 'Aclara para qué necesitas el dinero, revisa el expediente y compara condiciones completas. Si no puedes sostener la cuota, el préstamo no es una salida real.' -Faqs @(@{ q = '¿Estar en ASNEF impide pedir un préstamo?'; a = 'No siempre lo impide, pero sí puede dificultarlo mucho o empeorar las condiciones ofrecidas.' }, @{ q = '¿Conviene intentar muchas solicitudes a la vez?'; a = 'No suele ser la mejor idea si no has ordenado antes tu situación y lo que realmente buscas.' }, @{ q = '¿Puede ser mejor regularizar la incidencia antes de pedir financiación?'; a = 'En muchos casos sí, especialmente si ya tienes margen para acreditar pago o discutir un error.' }) -Related @(@{ href = 'pages/salir-de-asnef.html'; label = 'Guía para salir de ASNEF con método' }, @{ href = 'articulos/que-implica-aparecer-en-asnef.html'; label = 'Qué efectos reales tiene aparecer en ASNEF' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas ordenar la estrategia' }) -ReadTime '11 min de lectura')
)

$generatedArticlePages += @(
  (New-TopicArticle -Path 'articulos/asnef-y-hipoteca-opciones-realistas.html' -Title 'ASNEF e hipoteca: opciones realistas antes de iniciar una solicitud importante' -Description 'Qué revisar si piensas pedir una hipoteca y existe una incidencia en ASNEF, con un enfoque realista y ordenado.' -Category 'ASNEF e hipoteca' -Eyebrow 'Artículo SEO' -Headline 'La hipoteca exige un expediente limpio o, al menos, muy bien entendido.' -Lead 'La preocupación por ASNEF se vuelve especialmente intensa cuando aparece una posible hipoteca. Y es lógico: ya no hablamos de una compra menor, sino de una operación de gran tamaño donde cualquier incidencia pesa mucho más.' -Lead2 'Por eso conviene ser realista. Antes de iniciar solicitudes, tasaciones o conversaciones que generen expectativas, merece la pena revisar qué incidencia existe, qué prueba tienes y si el momento es adecuado para moverte.' -SideTitle 'Qué enfoca' -SideText 'Que el tamaño de la operación hace todavía más importante la preparación documental.' -ReviewPoint 'En una hipoteca no solo importa la existencia del dato, sino también su naturaleza, antigüedad, importe y estado actual. No es lo mismo una deuda discutida y pequeña que una incidencia activa sin explicación documental clara.' -ContextPoint 'Además, la operación hipotecaria exige mucha más documentación general. Si el expediente de solvencia está desordenado, esa carga adicional puede hacerte perder tiempo y oportunidades antes incluso de llegar al análisis serio de la entidad.' -ActionPoint 'La actuación más sensata suele ser ordenar primero tu mapa completo: ingresos, ahorros, estabilidad laboral y expediente de ASNEF. Con esa foto ya puedes decidir si conviene intentar la operación, posponerla o centrarte antes en limpiar o explicar la incidencia.' -DecisionPoint 'A veces la mejor decisión no es correr a pedir una hipoteca, sino usar unas semanas para regularizar, acreditar pago o cerrar una reclamación que de otro modo acompañará toda la negociación con el banco.' -DocsIntro 'Para valorar una hipoteca con una incidencia abierta, necesitas documentos financieros y de solvencia en paralelo.' -DocumentList @('Información actualizada sobre la incidencia en ASNEF.', 'Justificantes de ingresos, estabilidad y ahorro.', 'Documentación de deudas activas y cuotas mensuales.', 'Cualquier prueba de pago, acuerdo o reclamación vinculada al dato.') -MistakeIntro 'El error más repetido es empezar el proceso hipotecario sin haber decidido cómo explicar o resolver la incidencia.' -MistakeList @('Confiar en que el banco “ya verá” el contexto sin que tú lo ordenes.', 'Pagar señales o asumir gastos previos sin revisar el expediente.', 'Pensar que una deuda pequeña siempre será irrelevante.', 'No distinguir entre una incidencia regularizada y una aún discutida o abierta.') -NextTitle 'Cómo preparar el terreno' -NextText 'Antes de mover una operación tan exigente, ordena tu solvencia y la incidencia. Esa preparación vale mucho más que la velocidad de la primera solicitud.' -Faqs @(@{ q = '¿Una incidencia pequeña impide toda hipoteca?'; a = 'No puede resumirse así. El impacto depende del expediente completo y de cómo lo valore la entidad.' }, @{ q = '¿Conviene esperar a salir de ASNEF antes de pedir hipoteca?'; a = 'En muchos casos es una estrategia más prudente, sobre todo si la regularización está cerca o es defendible.' }, @{ q = '¿Hace falta reunir mucha documentación?'; a = 'Sí. Las operaciones hipotecarias exigen bastante más preparación, así que el orden previo resulta clave.' }) -Related @(@{ href = 'pages/salir-de-asnef.html'; label = 'Qué hacer si quieres salir del fichero' }, @{ href = 'articulos/asnef-y-prestamos-que-mirar-antes-de-pedir-financiacion.html'; label = 'Préstamos y financiación con ASNEF' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial para revisar el expediente' }) -ReadTime '11 min de lectura'),
  (New-TopicArticle -Path 'articulos/asnef-sin-carta-de-inclusion.html' -Title 'ASNEF sin carta de inclusión: cómo orientarte cuando no conservas la notificación' -Description 'Qué hacer si sospechas que estás en ASNEF pero no tienes la carta de inclusión o ya no conservas la referencia.' -Category 'ASNEF sin carta de inclusión' -Eyebrow 'Artículo SEO' -Headline 'No tener la carta complica, pero no deja el caso a ciegas.' -Lead 'Una situación bastante común es sospechar que existe una incidencia en ASNEF y no conservar la carta de inclusión. A veces nunca se localizó, otras se perdió o quedó mezclada entre otras comunicaciones. Eso genera mucha sensación de bloqueo, pero no significa que no puedas empezar a ordenar el caso.' -Lead2 'Lo importante es aceptar que sin carta necesitarás trabajar mejor el resto del expediente: señales, deudas asociadas, identificación y cronología.' -SideTitle 'Qué desbloquea' -SideText 'Te orienta cuando falta la referencia más cómoda y toca reconstruir el caso con otras pistas.' -ReviewPoint 'Sin carta, conviene revisar denegaciones recientes, correos de acreedores, llamadas de recobro, facturas pendientes o cualquier documento que apunte a una deuda concreta. Esas piezas sirven para acotar el escenario.' -ContextPoint 'Muchas personas se atascan porque creen que sin la notificación no pueden avanzar. En realidad, la carta ayuda mucho, pero lo esencial sigue siendo identificar el expediente y reunir suficiente contexto para que la consulta tenga sentido.' -ActionPoint 'Empieza por una cronología mínima y por una lista de acreedores potencialmente relacionados. Si has tenido varias incidencias, sepáralas. Esa limpieza previa evita consultas desordenadas y te ayuda a interpretar mejor cualquier respuesta que recibas.' -DecisionPoint 'Cuando logres confirmar el dato, no te quedes solo con el alivio de haber salido de dudas. Guarda la referencia nueva y úsala para ordenar el resto del caso, porque sin esa disciplina documental volverás a quedarte sin hilo muy rápido.' -DocsIntro 'En ausencia de carta, gana valor cualquier documento que te acerque al origen y al momento de la incidencia.' -DocumentList @('Documento identificativo.', 'Mensajes, correos o reclamaciones de acreedores.', 'Denegaciones recientes que hayan activado la sospecha.', 'Resumen de deudas, servicios o contratos problemáticos.') -MistakeIntro 'El error más típico es consultar sin haber separado antes las posibles incidencias.' -MistakeList @('Buscar una respuesta instantánea sin preparar contexto.', 'No anotar qué acreedor podría estar detrás.', 'Perder la nueva referencia una vez obtenida.', 'Confiar en recuerdos vagos sobre importes o fechas.') -NextTitle 'Cómo reconstruir el caso sin la carta' -NextText 'Haz una lista de deudas o servicios conflictivos, ordénalos por fecha y usa esa base para consultar de forma mucho más útil.' -Faqs @(@{ q = '¿Puedo saber si estoy en ASNEF sin la carta?'; a = 'Sí, aunque la falta de referencia obliga a preparar mejor la consulta y el contexto documental.' }, @{ q = '¿La carta es imprescindible para reclamar?'; a = 'Ayuda, pero no siempre es imprescindible si puedes reconstruir el expediente por otras vías.' }, @{ q = '¿Qué hago si sospecho varias deudas diferentes?'; a = 'Sepáralas por acreedor, importe y fecha para no mezclar escenarios distintos.' }) -Related @(@{ href = 'pages/consultar-asnef.html'; label = 'Guía principal sobre consulta' }, @{ href = 'articulos/como-saber-si-estoy-en-asnef.html'; label = 'Cómo saber si estás en ASNEF' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si necesitas reconstruir el expediente' }) -ReadTime '10 min de lectura')
)

$generatedArticlePages += @(
  (New-TopicArticle -Path 'articulos/reclamar-inclusion-indebida-asnef.html' -Title 'Reclamar una inclusión indebida en ASNEF: enfoque práctico para ordenar la revisión' -Description 'Cómo preparar una reclamación por inclusión indebida en ASNEF, qué demostrar y qué errores evitar.' -Category 'Reclamar inclusión indebida' -Eyebrow 'Artículo SEO' -Headline 'Una reclamación útil empieza por definir muy bien qué consideras indebido.' -Lead 'No toda reclamación por ASNEF se sostiene de la misma manera. A veces el problema es una deuda discutida; otras, un importe erróneo, un pago no reflejado o una comunicación que nunca debió terminar en un fichero de solvencia. Por eso la palabra “indebida” necesita concretarse.' -Lead2 'Este artículo se centra en ese punto: cómo delimitar el motivo de la reclamación y cómo construir una revisión más clara y más defendible.' -SideTitle 'Qué ordena' -SideText 'Te ayuda a pasar de la indignación genérica a una reclamación con objeto y prueba.' -ReviewPoint 'Lo primero es identificar si lo indebido está en la existencia de la deuda, en su importe, en la persona afectada, en el estado actual del pago o en la propia base documental de la comunicación. Sin ese foco, la reclamación pierde fuerza muy deprisa.' -ContextPoint 'También conviene distinguir entre reclamar al acreedor, reclamar la rectificación del dato o hacer ambas cosas con una estrategia coherente. Mezclar todos los frentes sin orden suele volver el caso mucho más opaco.' -ActionPoint 'La reclamación práctica suele ser breve: explica qué dato consideras indebido, por qué lo consideras así y con qué prueba lo respaldas. Si el caso es más complejo, la claridad en la estructura compensa mejor que la longitud del escrito.' -DecisionPoint 'Conviene además ajustar expectativas. Una reclamación no siempre implica respuesta inmediata ni corrección automática, pero sí crea un rastro importante y obliga a sostener el caso sobre algo más que una llamada o un desacuerdo verbal.' -DocsIntro 'Para reclamar de forma útil, necesitas documentos que conecten el error con un hecho verificable.' -DocumentList @('Documento o referencia donde conste la inclusión.', 'Pruebas de pago, cancelación o incidencia discutida.', 'Contrato, factura o documento de origen de la deuda.', 'Comunicaciones previas con el acreedor o gestor.') -MistakeIntro 'El error que más debilita una reclamación es no concretar qué parte exacta del dato es indebida.' -MistakeList @('Reclamar con mensajes genéricos sin prueba asociada.', 'Enviar muchos documentos sin explicar la relación entre ellos.', 'No conservar referencias, acuses o fechas de envío.', 'Cambiar de argumento según el canal utilizado.') -NextTitle 'Cómo empezar una reclamación mejor enfocada' -NextText 'Define en una línea qué dato impugnas, escoge la prueba principal y construye una cronología breve. Esa base hace mucho más sólida la revisión.' -Faqs @(@{ q = '¿Incluirme en ASNEF y no estar de acuerdo ya significa inclusión indebida?'; a = 'No basta con el desacuerdo. Necesitas concretar por qué el dato sería incorrecto o improcedente y con qué prueba cuentas.' }, @{ q = '¿Debo reclamar primero al acreedor?'; a = 'Depende del caso, pero muchas veces revisar el origen con el acreedor es una pieza clave del expediente.' }, @{ q = '¿Conviene guardar todas las referencias de envío?'; a = 'Sí. Son fundamentales para seguir el caso con orden.' }) -Related @(@{ href = 'pages/reclamar-asnef.html'; label = 'Guía general sobre reclamaciones' }, @{ href = 'articulos/baja-asnef-por-error-documentos-clave.html'; label = 'Documentos clave para rectificar errores' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial para revisar la estrategia' }) -ReadTime '11 min de lectura'),
  (New-TopicArticle -Path 'articulos/deuda-pequena-asnef-merece-la-pena-regularizar.html' -Title 'Deuda pequeña en ASNEF: cuándo merece la pena regularizar y cuándo conviene revisar más' -Description 'Cómo pensar una deuda pequeña en ASNEF sin caer en respuestas automáticas ni gastos innecesarios.' -Category 'Deuda pequeña en ASNEF' -Eyebrow 'Artículo SEO' -Headline 'El importe pequeño no siempre significa problema pequeño.' -Lead 'Una de las trampas más frecuentes es restar importancia a una deuda pequeña o, por el contrario, pagarla de inmediato sin entender bien el expediente. El hecho de que el importe sea reducido no elimina la necesidad de revisar contexto, origen y objetivo.' -Lead2 'Este contenido te ayuda a pensar con más criterio si una deuda pequeña merece regularización inmediata, discusión previa o simplemente una mejor lectura del caso.' -SideTitle 'Qué matiza' -SideText 'Que el importe importa, pero no sustituye el análisis del dato, el uso que necesitas dar a tu solvencia y la prueba disponible.' -ReviewPoint 'Conviene empezar por una pregunta muy simple: qué efecto práctico está teniendo esa deuda. No es igual una incidencia pequeña que bloquea una financiación relevante que otra que de momento solo genera preocupación preventiva.' -ContextPoint 'También influye mucho si el importe es correcto, si lo reconoces, si ya hubo pagos parciales o si la discusión real está en el servicio, contrato o penalización de origen. Ahí es donde se decide si regularizar rápido es razonable o precipitado.' -ActionPoint 'Si el dato es correcto y necesitas despejar una operación importante, puede tener sentido regularizar cuanto antes y dejar todo muy bien documentado. Si el problema es dudoso o la deuda nace de un cargo cuestionable, quizá convenga revisar antes de pagar por simple cansancio.' -DecisionPoint 'La decisión útil no se basa solo en el número. Se basa en combinación de cuatro factores: corrección del dato, impacto actual, coste de seguir discutiendo y capacidad de cerrar el expediente con buena prueba.' -DocsIntro 'Aunque el importe sea bajo, conviene reunir la documentación básica con el mismo cuidado que en casos mayores.' -DocumentList @('Factura o documento que origine el importe.', 'Prueba de cualquier pago o gestión previa.', 'Referencia de inclusión o comunicación relacionada.', 'Contexto de la operación que quieres desbloquear, si existe.') -MistakeIntro 'El error más común es pensar que por ser poco dinero no merece la pena revisar nada.' -MistakeList @('Pagar solo por agotamiento sin entender el origen.', 'Ignorar el impacto que puede tener sobre otra operación importante.', 'No guardar justificantes porque “es una cantidad pequeña”.', 'Discutir indefinidamente una incidencia menor sin estrategia clara.') -NextTitle 'Cómo decidir con más criterio' -NextText 'Valora impacto, corrección del dato y coste de oportunidad. Una deuda pequeña puede merecer regularización rápida o una revisión previa, según el caso.' -Faqs @(@{ q = '¿Por ser una deuda pequeña debería pagar sin más?'; a = 'No siempre. Primero conviene revisar si el dato es correcto y qué efecto práctico está teniendo.' }, @{ q = '¿Una incidencia pequeña puede bloquear financiación?'; a = 'Puede influir en determinadas operaciones, por eso es importante valorar el contexto real.' }, @{ q = '¿Merece la pena guardar prueba incluso si el importe es mínimo?'; a = 'Sí. La prueba importa igual, aunque la cuantía sea reducida.' }) -Related @(@{ href = 'articulos/cancelar-asnef-despues-de-pagar.html'; label = 'Cómo documentar la baja tras el pago' }, @{ href = 'pages/salir-de-asnef.html'; label = 'Guía práctica para salir de ASNEF' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial si dudas entre pagar o revisar' }) -ReadTime '10 min de lectura'),
  (New-TopicArticle -Path 'articulos/asnef-y-segunda-oportunidad-primeras-claves.html' -Title 'ASNEF y Ley de Segunda Oportunidad: primeras claves antes de mezclar expectativas' -Description 'Cómo encajar ASNEF dentro de una posible reflexión sobre Segunda Oportunidad sin convertirlo en una promesa automática.' -Category 'ASNEF y Segunda Oportunidad' -Eyebrow 'Artículo SEO' -Headline 'Segunda Oportunidad y ASNEF no son la misma conversación, aunque a veces se crucen.' -Lead 'Cuando la presión por deuda es alta, es normal que aparezca la idea de la Ley de Segunda Oportunidad junto con la preocupación por ASNEF. El problema empieza cuando ambas cuestiones se mezclan como si fueran una solución inmediata y única para cualquier caso.' -Lead2 'Este artículo intenta poner orden: qué papel juega ASNEF en esa reflexión, qué preguntas conviene hacerse primero y por qué no deberías comprar un relato simplificado.' -SideTitle 'Qué separa' -SideText 'Distingue entre una incidencia de solvencia concreta y un escenario más amplio de sobreendeudamiento.' -ReviewPoint 'Lo primero es entender si el problema central es el fichero, la imposibilidad de sostener varias deudas, una negociación fallida o un contexto más estructural. Sin ese diagnóstico mínimo, hablar de Segunda Oportunidad puede ser prematuro.' -ContextPoint 'ASNEF puede ser una consecuencia visible del problema, pero no siempre es el núcleo. A veces la prioridad es regularizar una deuda concreta; otras, revisar si la situación financiera general exige estudiar alternativas más profundas.' -ActionPoint 'La actuación prudente pasa por ordenar ingresos, deudas, pagos pendientes, incidencias y documentación. Ese trabajo previo permite diferenciar entre un expediente que quizá se resuelve con reclamación o pago y otro que obliga a plantear medidas más ambiciosas.' -DecisionPoint 'También conviene alejarse de mensajes comerciales que prometen borrados rápidos o soluciones universales. En asuntos de insolvencia personal, el encaje de cada vía depende mucho de la realidad económica y documental de quien consulta.' -DocsIntro 'Si el caso te hace pensar en una solución más amplia, conviene reunir una fotografía económica bastante más completa.' -DocumentList @('Resumen de ingresos y gastos mensuales.', 'Listado de deudas, acreedores e incidencias abiertas.', 'Información sobre ASNEF u otros ficheros si existe.', 'Documentación de acuerdos, pagos incumplidos o reclamaciones previas.') -MistakeIntro 'El error principal es tratar ASNEF como si explicara por sí solo todo el problema financiero.' -MistakeList @('Confundir salida del fichero con solución integral de la deuda.', 'Buscar una vía compleja sin haber ordenado antes la situación económica.', 'Aceptar promesas automáticas sobre resultados.', 'No separar deudas discutidas de deudas reconocidas y sostenidas en el tiempo.') -NextTitle 'Cómo empezar a aclarar el mapa' -NextText 'Define si tu problema principal es una incidencia concreta en ASNEF o un sobreendeudamiento más amplio. Esa distinción cambia por completo la estrategia.' -Faqs @(@{ q = '¿Salir de ASNEF equivale a resolver un problema de sobreendeudamiento?'; a = 'No. Puede ayudar, pero no sustituye el análisis global de la situación económica.' }, @{ q = '¿La Ley de Segunda Oportunidad borra automáticamente cualquier incidencia?'; a = 'No debe entenderse así. Es una materia más compleja y dependiente de cada caso.' }, @{ q = '¿Tiene sentido ordenar primero documentación e ingresos?'; a = 'Sí. Ese trabajo previo es esencial para valorar cualquier vía con realismo.' }) -Related @(@{ href = 'pages/segunda-oportunidad.html'; label = 'Guía sobre Ley de Segunda Oportunidad' }, @{ href = 'pages/salir-de-asnef.html'; label = 'Qué hacer si tu prioridad es el fichero' }, @{ href = 'pages/contacto.html'; label = 'Consulta inicial para orientar el caso' }) -ReadTime '11 min de lectura')
)

$legacyGuideEntries = @(
  @{ Path = 'pages/asnef.html'; Title = 'Qué es ASNEF y cómo funciona'; Description = 'Guía general sobre el fichero y su impacto práctico.'; Category = 'Guía general ASNEF' },
  @{ Path = 'pages/reclamar-asnef.html'; Title = 'Cómo reclamar errores en ASNEF'; Description = 'Ruta documental para revisar datos inexactos.'; Category = 'Reclamaciones ASNEF' },
  @{ Path = 'pages/embargos.html'; Title = 'Embargos y deudas'; Description = 'Qué revisar cuando la presión sube de nivel.'; Category = 'Embargos' },
  @{ Path = 'pages/negociar-deudas.html'; Title = 'Negociar deudas con criterio'; Description = 'Cuotas, plazos y soporte escrito.'; Category = 'Negociación de deudas' },
  @{ Path = 'pages/prescripcion-deudas.html'; Title = 'Prescripción de deudas'; Description = 'Cronología, fechas y errores frecuentes.'; Category = 'Prescripción' },
  @{ Path = 'pages/reunificacion.html'; Title = 'Reunificación de deudas'; Description = 'Cuándo ayuda y cuándo solo compra tiempo.'; Category = 'Reunificación' },
  @{ Path = 'pages/segunda-oportunidad.html'; Title = 'Ley de Segunda Oportunidad'; Description = 'Qué revisar antes de valorar esta vía.'; Category = 'Segunda Oportunidad' }
)

$legacyBlogEntries = @()

$blogEntries = @()
$blogEntries += $generatedArticlePages
$blogEntries += $legacyBlogEntries

foreach ($page in $categoryPages) {
  $activeKey = switch ($page.Path) {
    'pages/consultar-asnef.html' { 'consultar' }
    'pages/derechos-usuario.html' { 'derechos' }
    default { 'salir' }
  }
  Write-Utf8NoBom -Path (Join-Path $root $page.Path) -Content (Render-EditorialPage -Page $page -RelativePath $page.Path -ActiveKey $activeKey -Kind 'guide')
}

foreach ($page in $generatedArticlePages) {
  Write-Utf8NoBom -Path (Join-Path $root $page.Path) -Content (Render-EditorialPage -Page $page -RelativePath $page.Path -ActiveKey 'blog' -Kind 'article')
}

$homeCards = foreach ($page in $categoryPages) {
  @"
<article class="summary-guide-card">
  <span class="card-tag">$([System.Net.WebUtility]::HtmlEncode($page.Category))</span>
  <h3>$([System.Net.WebUtility]::HtmlEncode($page.Title))</h3>
  <p>$([System.Net.WebUtility]::HtmlEncode($page.Description))</p>
  <a class="card-link" href="$($page.Path)">Leer guía</a>
</article>
"@
}

$guideCards = foreach ($page in $legacyGuideEntries) {
  @"
<article class="info-card">
  <span class="card-tag">$([System.Net.WebUtility]::HtmlEncode($page.Category))</span>
  <h3>$([System.Net.WebUtility]::HtmlEncode($page.Title))</h3>
  <p>$([System.Net.WebUtility]::HtmlEncode($page.Description))</p>
  <a class="card-link" href="$($page.Path)">Abrir guía</a>
</article>
"@
}

$articleCards = foreach ($page in ($blogEntries | Select-Object -First 6)) {
  @"
<article class="info-card">
  <span class="card-tag">$([System.Net.WebUtility]::HtmlEncode($page.Category))</span>
  <h3>$([System.Net.WebUtility]::HtmlEncode($page.Title))</h3>
  <p>$([System.Net.WebUtility]::HtmlEncode($page.Description))</p>
  <a class="card-link" href="$($page.Path)">Leer artículo</a>
</article>
"@
}

$homeMain = @"
<main id="main-content">
  <section class="hero">
    <div class="container hero-grid">
      <div class="panel hero-copy">
        <p class="eyebrow accent">Información financiera y jurídica en lenguaje claro</p>
        <h1>Salir de ASNEF, consultar tus datos y entender tus derechos sin promesas agresivas.</h1>
        <p class="hero-intro">Solución ASNEF ordena la información que más busca el mercado español: cómo salir del fichero, cómo consultar la inclusión, qué canales sirven de verdad y qué errores suelen alargar una incidencia.</p>
        <div class="hero-actions">
          <a class="button button-primary" href="pages/salir-de-asnef.html">Salir de ASNEF</a>
          <a class="button button-secondary" href="pages/consultar-asnef.html">Consultar ASNEF</a>
        </div>
      </div>
      <aside class="content-sidebar">
        <p class="eyebrow">Base de publicación</p>
        <ul>
          <li>Cookies con aceptar y rechazar al mismo nivel.</li>
          <li>Legales completos y contacto visible.</li>
          <li>Contenido separado de la publicidad.</li>
          <li>Arquitectura clara de categorías y blog.</li>
        </ul>
      </aside>
    </div>
  </section>
  <section class="section section-light">
    <div class="container">
      <div class="section-heading">
        <p class="eyebrow">Categorías SEO</p>
        <h2>Empieza por la pregunta correcta.</h2>
      </div>
      <div class="summary-guide-grid">
        $($homeCards -join "`n")
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container">
      <div class="section-heading">
        <p class="eyebrow">Guías largas</p>
        <h2>Pilares editoriales para consultas recurrentes.</h2>
      </div>
      <div class="cards-grid">
        $($guideCards -join "`n")
      </div>
    </div>
  </section>
  <section class="section section-light">
    <div class="container">
      $(Ad-SlotHtml -SlotKey 'topBannerSlot' -AriaLabel 'Publicidad discreta en portada' -Title 'Bloque amplio pensado para monetizar la portada sin romper el ritmo de lectura ni el primer scroll.' -Meta 'Se sitúa entre rutas editoriales, no encima del hero, para mantener una entrada limpia y poco invasiva.' -Classes 'ad-slot-wide')
    </div>
  </section>
  <section class="section section-muted">
    <div class="container">
      <div class="section-heading">
        <p class="eyebrow">Artículos destacados</p>
        <h2>Contenido diseñado para búsqueda orgánica y lectura útil.</h2>
      </div>
      <div class="cards-grid">
        $($articleCards -join "`n")
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container">
      $(Ad-SlotHtml -SlotKey 'bottomSlot' -AriaLabel 'Publicidad final en portada' -Title 'Bloque final preparado para una segunda impresión publicitaria al cierre de la portada.' -Meta 'Aparece al final del recorrido principal para que la home siga sintiéndose editorial y no promocional.' -Classes 'ad-slot-wide')
    </div>
  </section>
</main>
"@

Write-Utf8NoBom -Path (Join-Path $root 'index.html') -Content (Page-Shell -RelativePath 'index.html' -BodyClass 'theme-home page-home' -Title 'ASNEF, cancelación, consulta y derechos del usuario | Solución ASNEF' -Description 'Portal sobre ASNEF, deuda y solvencia con estructura profesional, contenido SEO y base compatible con buenas prácticas de AdSense.' -ActiveKey 'home' -MainContent $homeMain -JsonLdBlocks @((Organization-JsonLd), (Breadcrumb-JsonLd @(@{ label = 'Inicio'; href = 'index.html'; absolute = $site.Url }))))

$blogCards = foreach ($page in $blogEntries) {
  $cardHref = Get-RelativeHref -FromRelativePath 'articulos/index.html' -ToRelativePath $page.Path
  @"
<article class="summary-guide-card" data-article-card data-search-value="$([System.Net.WebUtility]::HtmlEncode("$($page.Title) $($page.Description) $($page.Category)"))">
  <span class="card-tag">$([System.Net.WebUtility]::HtmlEncode($page.Category))</span>
  <h3>$([System.Net.WebUtility]::HtmlEncode($page.Title))</h3>
  <p>$([System.Net.WebUtility]::HtmlEncode($page.Description))</p>
  <a class="card-link" href="$cardHref">Leer artículo</a>
</article>
"@
}

$blogMain = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container page-hero-grid">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Artículos</p>
        <p class="eyebrow accent">Centro editorial</p>
        <h1>Artículos sobre ASNEF, consulta, plazos y cancelación.</h1>
        <p class="content-lead">El centro editorial reúne $($blogEntries.Count) piezas largas sobre ASNEF, consulta, cancelación, plazos, reclamaciones y contextos frecuentes. La búsqueda local te ayuda a filtrar por intención y encontrar una ruta de lectura útil.</p>
      </div>
      <aside class="content-sidebar content-sidebar-stack">
        <label for="article-search">Buscar</label>
        <input id="article-search" type="search" data-article-search placeholder="salir, tiempo, teléfono, consulta..." />
        <p class="search-results-summary" data-search-summary></p>
        $(Ad-SlotHtml -SlotKey 'inContentSlot' -AriaLabel 'Publicidad lateral del centro editorial' -Title 'Hueco lateral para monetizar el índice sin romper la búsqueda interna.' -Meta 'Se mantiene en la columna secundaria para que el grid principal siga siendo el foco.' -Classes 'ad-slot-compact')
      </aside>
    </div>
  </section>
  <section class="section section-light">
    <div class="container">
      $(Ad-SlotHtml -SlotKey 'topBannerSlot' -AriaLabel 'Publicidad superior del centro editorial' -Title 'Bloque superior listo para monetizar el listado de artículos con un formato amplio y limpio.' -Meta 'Aparece después del hero, cuando el usuario ya entiende el propósito de la página.' -Classes 'ad-slot-wide')
    </div>
  </section>
  <section class="section">
    <div class="container">
      <div class="summary-guide-grid">
        $($blogCards -join "`n")
      </div>
    </div>
  </section>
  <section class="section section-muted">
    <div class="container">
      $(Ad-SlotHtml -SlotKey 'bottomSlot' -AriaLabel 'Publicidad final del centro editorial' -Title 'Bloque final pensado para una segunda exposición publicitaria antes de abandonar el índice.' -Meta 'Refuerza el inventario del centro editorial sin recargar el arranque de la navegación.' -Classes 'ad-slot-wide')
    </div>
  </section>
</main>
"@

Write-Utf8NoBom -Path (Join-Path $root 'articulos/index.html') -Content (Page-Shell -RelativePath 'articulos/index.html' -BodyClass 'theme-home page-articulos' -Title 'Artículos sobre ASNEF, consulta gratis, tiempos y cancelación | Solución ASNEF' -Description 'Índice de artículos SEO sobre ASNEF: consulta, salida, teléfono, baja tras pago y plazos.' -ActiveKey 'blog' -MainContent $blogMain -JsonLdBlocks @((Organization-JsonLd), (Breadcrumb-JsonLd @(@{ label = 'Inicio'; href = '../index.html'; absolute = $site.Url }, @{ label = 'Artículos'; href = ''; absolute = (Join-Url 'articulos/index.html') }))))

$aboutMain = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container page-hero-grid">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Sobre nosotros</p>
        <p class="eyebrow accent">Quién firma el contenido</p>
        <h1>Una web informativa pensada para reducir ruido y mejorar decisiones.</h1>
        <p class="content-lead">Solución ASNEF nace para explicar con claridad cómo leer un expediente de deuda o de solvencia antes de tomar decisiones que pueden tener impacto económico real.</p>
      </div>
      <aside class="content-sidebar">
        <p class="eyebrow">Compromisos editoriales</p>
        <ul>
          <li>Contenido editorial, no promesas de resultados.</li>
          <li>Separación visible entre anuncios y recomendaciones.</li>
          <li>Legales completos y responsable identificado.</li>
          <li>Lenguaje claro para usuarios no técnicos.</li>
        </ul>
      </aside>
    </div>
  </section>
  <section class="section section-light">
    <div class="container cards-grid">
      <article class="trust-card">
        <span class="card-tag">Responsable</span>
        <h2>$($site.Owner)</h2>
        <p>La web publica contenido firmado desde una lógica editorial: explicar mejor el problema, contextualizar opciones y evitar mensajes agresivos o confusos.</p>
      </article>
      <article class="trust-card">
        <span class="card-tag">Método</span>
        <h2>Información útil antes que urgencia comercial</h2>
        <p>El criterio de publicación se centra en ordenar expedientes, aclarar derechos y reducir errores de calendario o documentación, incluso cuando eso implique bajar expectativas.</p>
      </article>
      <article class="trust-card">
        <span class="card-tag">Transparencia</span>
        <h2>Contacto y legales visibles</h2>
        <p>El responsable, los canales de contacto y las políticas legales están visibles para que el sitio funcione como una web seria y verificable desde el primer vistazo.</p>
      </article>
    </div>
  </section>
  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-shell">
          <div class="content-body">
            <section>
              <h2>Qué hace realmente Solución ASNEF</h2>
              <p>La web no vende borrados instantáneos ni fórmulas universales. Su función principal es ordenar la información que una persona suele necesitar cuando descubre una incidencia en ASNEF, cuando duda sobre una deuda o cuando necesita interpretar un pago, una reclamación o una notificación de embargo sin perderse entre mensajes contradictorios.</p>
              <p>Ese enfoque exige trabajar con matices. En muchos expedientes la clave no está en repetir “salir de ASNEF”, sino en diferenciar entre deuda correcta, deuda discutida, pago ya realizado, inclusión errónea o simple falta de documentación. Por eso el contenido está organizado por intenciones reales de búsqueda y no por promesas llamativas.</p>
            </section>
            <section>
              <h2>Cómo se prepara el contenido</h2>
              <p>Cada guía intenta conectar tres capas: contexto, acción y documentación. Primero se explica qué está pasando; después se aterriza qué pasos suelen tener sentido; y por último se aclara qué prueba conviene guardar para no depender solo de llamadas o recuerdos incompletos.</p>
              <p>Además, el sitio mantiene una separación expresa entre bloques publicitarios y contenido editorial. Las recomendaciones no están escritas para forzar clics, sino para construir un recorrido de lectura más claro entre categorías, artículos y páginas legales.</p>
            </section>
            <section>
              <h2>Datos de identificación y contacto</h2>
              <ul>
                <li>Responsable editorial: $($site.Owner)</li>
                <li>Dirección de contacto: $($site.Address)</li>
                <li>Email general: $($site.Email)</li>
                <li>Email de privacidad: $($site.PrivacyEmail)</li>
                <li>Teléfono de contacto: $($site.Phone)</li>
              </ul>
            </section>
          </div>
        </div>
      </article>
      <aside class="content-sidebar">
        <p class="eyebrow">Rutas recomendadas</p>
        <ul>
          <li><a href="../pages/salir-de-asnef.html">Salir de ASNEF</a></li>
          <li><a href="../pages/consultar-asnef.html">Consultar ASNEF</a></li>
          <li><a href="../pages/derechos-usuario.html">Derechos del usuario</a></li>
          <li><a href="../pages/contacto.html">Formulario de contacto</a></li>
        </ul>
      </aside>
    </div>
  </section>
</main>
"@

Write-Utf8NoBom -Path (Join-Path $root 'pages/sobre-nosotros.html') -Content (Page-Shell -RelativePath 'pages/sobre-nosotros.html' -BodyClass 'theme-home page-about' -Title 'Sobre Solución ASNEF | Transparencia editorial y contacto real' -Description 'Quién está detrás de Solución ASNEF, cómo trabaja la web y qué compromisos editoriales mantiene.' -ActiveKey 'about' -MainContent $aboutMain -JsonLdBlocks @((Organization-JsonLd), (Breadcrumb-JsonLd @(@{ label = 'Inicio'; href = '../index.html'; absolute = $site.Url }, @{ label = 'Sobre nosotros'; href = ''; absolute = (Join-Url 'pages/sobre-nosotros.html') }))))

$contactMain = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container page-hero-grid">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Contacto</p>
        <p class="eyebrow accent">Consulta inicial</p>
        <h1>Cuéntanos el caso con los datos mínimos necesarios.</h1>
        <p class="content-lead">La revisión inicial es informativa. Explica la deuda, la entidad implicada, la fase del problema y la documentación disponible.</p>
      </div>
      <aside class="content-sidebar">
        <p class="eyebrow">Canales directos</p>
        <ul>
          <li>Email: <a href="mailto:$($site.Email)">$($site.Email)</a></li>
          <li>Teléfono: <a href="tel:$($site.Phone)">$($site.Phone)</a></li>
          <li>Respuesta orientativa: $($site.FormResponse)</li>
          <li>Privacidad: <a href="mailto:$($site.PrivacyEmail)">$($site.PrivacyEmail)</a></li>
        </ul>
      </aside>
    </div>
  </section>
  <section class="section section-light">
    <div class="container contact-grid">
      <div class="panel">
        <h2>Formulario seguro</h2>
        <p>Cuanto más clara sea la cronología, más útil será la revisión inicial. Resume la deuda, la entidad implicada, qué ha ocurrido hasta ahora y qué documentos puedes aportar.</p>
        <form class="lead-form compact-form" data-lead-form novalidate>
          <div class="form-grid-2">
            <label>Nombre completo<input type="text" name="nombre" required /></label>
            <label>Correo electrónico<input type="email" name="email" required /></label>
            <label>Tema principal<input type="text" name="tema" required /></label>
            <label>Teléfono <span class="field-hint">(opcional)</span><input type="tel" name="telefono" /></label>
          </div>
          <input type="hidden" name="interes" value="Consulta inicial desde contacto" />
          <label>Importe aproximado<input type="text" name="importe_deuda" /></label>
          <label>Mensaje<textarea name="mensaje" required></textarea></label>
          <label class="honeypot-field" aria-hidden="true">No rellenes este campo<input type="text" name="website" tabindex="-1" autocomplete="off" /></label>
          <label class="consent-label"><input type="checkbox" name="consentimiento" required />Acepto la <a href="../legal/politica-privacidad.html">política de privacidad</a> y autorizo el tratamiento de mis datos para responder a esta consulta.</label>
          <button type="submit" class="button button-primary button-block">Enviar consulta</button>
          <p class="form-feedback" data-form-feedback aria-live="polite"></p>
        </form>
      </div>
      <aside class="content-sidebar">
        <p class="eyebrow">Antes de enviar</p>
        <ul>
          <li>Identifica la deuda o servicio relacionado.</li>
          <li>Indica si ya pagaste, reclamaste o negociaste.</li>
          <li>Menciona fechas aproximadas y documentación disponible.</li>
          <li>No envíes datos sensibles innecesarios en el primer mensaje.</li>
        </ul>
      </aside>
    </div>
  </section>
  <section class="section">
    <div class="container cards-grid">
      <article class="info-card">
        <span class="card-tag">Paso 1</span>
        <h2>Recepción y lectura inicial</h2>
        <p>La consulta entra en una bandeja privada y se revisa con enfoque informativo. El objetivo inicial es entender qué tipo de incidencia tienes delante y si faltan piezas clave.</p>
      </article>
      <article class="info-card">
        <span class="card-tag">Paso 2</span>
        <h2>Orden documental</h2>
        <p>Si el caso lo requiere, la respuesta se centrará en qué conviene reunir o aclarar antes de pagar, reclamar, negociar o iniciar otra vía.</p>
      </article>
      <article class="info-card">
        <span class="card-tag">Paso 3</span>
        <h2>Siguiente paso razonable</h2>
        <p>La orientación intenta proponerte el movimiento más sensato según el expediente: consulta, regularización, revisión del dato o lectura de una guía concreta.</p>
      </article>
    </div>
  </section>
</main>
"@

Write-Utf8NoBom -Path (Join-Path $root 'pages/contacto.html') -Content (Page-Shell -RelativePath 'pages/contacto.html' -BodyClass 'theme-home page-contact' -Title 'Contacto | Consulta inicial sobre ASNEF, deuda o reclamaciones' -Description 'Formulario y datos de contacto para una consulta inicial sobre ASNEF, cancelación, reclamaciones y solvencia.' -ActiveKey 'contact' -MainContent $contactMain -JsonLdBlocks @((Organization-JsonLd), (Breadcrumb-JsonLd @(@{ label = 'Inicio'; href = '../index.html'; absolute = $site.Url }, @{ label = 'Contacto'; href = ''; absolute = (Join-Url 'pages/contacto.html') }))))

$legalPages = @(
  [ordered]@{
    Path = 'legal/aviso-legal.html'
    Title = 'Aviso legal'
    Description = 'Identificación del titular, objeto del sitio, responsabilidad, propiedad intelectual y normativa aplicable.'
    Main = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Aviso legal</p>
        <p class="eyebrow accent">Información legal</p>
        <h1>Aviso legal</h1>
        <p class="content-lead">Este sitio ofrece contenido informativo sobre ASNEF, deuda, solvencia y reclamaciones. A continuación se detallan los datos identificativos del responsable y las condiciones generales de uso.</p>
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-body">
          <section>
            <h2>Datos identificativos del titular</h2>
            <ul>
              <li>Responsable: $($site.Owner)</li>
              <li>Nombre del sitio: $($site.Name)</li>
              <li>Dirección: $($site.Address)</li>
              <li>Email de contacto: $($site.Email)</li>
              <li>Email de privacidad: $($site.PrivacyEmail)</li>
              <li>Teléfono: $($site.Phone)</li>
              <li>NIF o identificador fiscal informado por el titular: $($site.TaxId)</li>
            </ul>
          </section>
          <section>
            <h2>Objeto del sitio web</h2>
            <p>La finalidad de esta web es publicar contenido divulgativo y orientativo sobre inclusión en ficheros de solvencia, negociación de deudas, consulta de datos, reclamaciones y materias relacionadas. El contenido no constituye asesoramiento jurídico o financiero individualizado, ni sustituye una revisión profesional adaptada al caso concreto.</p>
            <p>El responsable se reserva el derecho a actualizar, modificar o retirar contenidos, servicios y elementos del sitio cuando resulte conveniente para mantener la calidad editorial, la seguridad del entorno o el cumplimiento normativo.</p>
          </section>
          <section>
            <h2>Condiciones de acceso y uso</h2>
            <p>El acceso al sitio tiene carácter gratuito, sin perjuicio del coste de conexión a internet que pueda asumir cada usuario. El usuario se compromete a utilizar la web de manera lícita, diligente y respetuosa, evitando conductas que puedan dañar el sitio, su disponibilidad o los derechos de terceros.</p>
            <p>No está permitido emplear los contenidos para finalidades ilícitas, enviar información falsa mediante formularios, intentar acceder a zonas restringidas sin autorización o usar herramientas automatizadas que comprometan el funcionamiento normal del sitio.</p>
          </section>
          <section>
            <h2>Propiedad intelectual y limitación de responsabilidad</h2>
            <p>Los textos, diseño, estructura, identidad visual y demás elementos del sitio están protegidos por la normativa aplicable en materia de propiedad intelectual e industrial. No se autoriza su reproducción, distribución o transformación más allá de los usos permitidos legalmente sin autorización previa del titular.</p>
            <p>El responsable procura que la información publicada sea clara, actualizada y útil, pero no garantiza la ausencia absoluta de errores, ni asume responsabilidad por decisiones adoptadas exclusivamente a partir del contenido del sitio. Las referencias a terceros o enlaces externos se facilitan con finalidad informativa y no suponen control permanente sobre dichos recursos.</p>
          </section>
          <section>
            <h2>Normativa aplicable y jurisdicción</h2>
            <p>Este aviso legal se interpreta conforme a la normativa española aplicable. Salvo que una norma imperativa disponga otra cosa, las controversias que puedan surgir en relación con el sitio se someterán a los juzgados y tribunales que correspondan según la legislación vigente.</p>
          </section>
        </div>
      </article>
      <aside class="content-sidebar">
        <p class="eyebrow">Documentos relacionados</p>
        <ul>
          <li><a href="politica-privacidad.html">Política de privacidad</a></li>
          <li><a href="politica-cookies.html">Política de cookies</a></li>
          <li><a href="terminos-condiciones.html">Condiciones de uso</a></li>
        </ul>
      </aside>
    </div>
  </section>
</main>
"@
  }
  [ordered]@{
    Path = 'legal/politica-privacidad.html'
    Title = 'Política de privacidad'
    Description = 'Tratamiento de datos, finalidades, bases legales, conservación, encargados y ejercicio de derechos.'
    Main = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Política de privacidad</p>
        <p class="eyebrow accent">Protección de datos</p>
        <h1>Política de privacidad</h1>
        <p class="content-lead">Esta política explica cómo se tratan los datos personales facilitados a través del formulario de contacto, los canales de correo electrónico y, en su caso, las funciones de cuenta disponibles en el sitio.</p>
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-body">
          <section>
            <h2>Responsable del tratamiento</h2>
            <p>El responsable del tratamiento de los datos personales recogidos a través de este sitio es $($site.Owner), con dirección de contacto en $($site.Address), correo electrónico $($site.Email) y dirección específica de privacidad $($site.PrivacyEmail).</p>
          </section>
          <section>
            <h2>Qué datos se tratan y con qué finalidad</h2>
            <p>Se tratan los datos que el usuario facilita voluntariamente al enviar una consulta: nombre, correo electrónico, teléfono si se aporta, asunto, descripción del caso, importe aproximado y cualquier información adicional incluida en el mensaje. La finalidad principal es atender la consulta, responder al usuario y mantener una comunicación relacionada con la solicitud realizada.</p>
            <p>Si el usuario utiliza funciones de cuenta o zonas privadas, podrán tratarse además datos de acceso, perfil y actividad estrictamente necesarios para prestar dicha funcionalidad. En todo caso, el tratamiento se limita a finalidades compatibles con la gestión del servicio, la seguridad y el cumplimiento de obligaciones legales.</p>
          </section>
          <section>
            <h2>Base jurídica y conservación</h2>
            <p>La base jurídica principal es el consentimiento del usuario al enviar el formulario o contactar por los canales publicados, así como la aplicación de medidas precontractuales o contractuales cuando la comunicación se refiera a una posible prestación de servicios o a una gestión ya iniciada.</p>
            <p>Los datos se conservarán durante el tiempo necesario para atender la consulta, realizar el seguimiento razonable de la comunicación y cumplir obligaciones legales o defensivas en caso de incidencias. Cuando dejen de ser necesarios, se suprimirán o bloquearán conforme a la normativa aplicable.</p>
          </section>
          <section>
            <h2>Destinatarios y proveedores técnicos</h2>
            <p>Los datos no se ceden a terceros salvo obligación legal o cuando resulte necesario para prestar las funcionalidades utilizadas por el usuario. El formulario de contacto puede ser procesado mediante Formspree como proveedor técnico de recepción de mensajes. Si el usuario emplea funciones de cuenta, determinados datos de acceso y perfil pueden gestionarse a través de Supabase como proveedor de infraestructura.</p>
            <p>Estos proveedores actúan como encargados o prestadores técnicos dentro de sus propios términos y medidas de seguridad. El responsable procura seleccionar herramientas razonablemente adecuadas y limitar el acceso a los datos a lo necesario para cada finalidad.</p>
          </section>
          <section>
            <h2>Derechos del usuario</h2>
            <p>El usuario puede ejercer los derechos de acceso, rectificación, supresión, oposición, limitación del tratamiento y portabilidad cuando resulten aplicables. Para ello puede escribir a $($site.PrivacyEmail) indicando su solicitud, datos identificativos y la información necesaria para tramitarla correctamente.</p>
            <p>Si considera que el tratamiento no se ajusta a la normativa, también puede presentar una reclamación ante la autoridad de control competente, sin perjuicio de intentar antes una solución directa a través de los canales de contacto del sitio.</p>
          </section>
        </div>
      </article>
      <aside class="content-sidebar">
        <p class="eyebrow">Contacto de privacidad</p>
        <ul>
          <li><a href="mailto:$($site.PrivacyEmail)">$($site.PrivacyEmail)</a></li>
          <li><a href="aviso-legal.html">Aviso legal</a></li>
          <li><a href="politica-cookies.html">Política de cookies</a></li>
        </ul>
      </aside>
    </div>
  </section>
</main>
"@
  }
  [ordered]@{
    Path = 'legal/politica-cookies.html'
    Title = 'Política de cookies'
    Description = 'Cookies técnicas, analíticas y publicitarias, gestión del consentimiento y revocación.'
    Main = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Política de cookies</p>
        <p class="eyebrow accent">Consentimiento y tecnologías de seguimiento</p>
        <h1>Política de cookies</h1>
        <p class="content-lead">Esta política explica qué cookies o tecnologías equivalentes puede utilizar el sitio, con qué finalidad y cómo se gestiona el consentimiento del usuario.</p>
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-body">
          <section>
            <h2>Qué son las cookies</h2>
            <p>Las cookies son pequeños archivos o tecnologías similares que permiten almacenar o recuperar información del dispositivo del usuario cuando navega por un sitio web. Pueden utilizarse para finalidades técnicas, analíticas, funcionales o publicitarias, según la configuración aplicada en cada momento.</p>
          </section>
          <section>
            <h2>Cookies técnicas necesarias</h2>
            <p>El sitio puede utilizar cookies técnicas imprescindibles para recordar preferencias básicas, mantener la navegación estable y gestionar el banner de consentimiento. Estas cookies son necesarias para el funcionamiento mínimo del sitio y no requieren consentimiento cuando su uso se limita a esa finalidad esencial.</p>
          </section>
          <section>
            <h2>Cookies analíticas y publicitarias</h2>
            <p>Las cookies analíticas y publicitarias solo se activan cuando el usuario presta su consentimiento a través del banner. Si se habilita analítica, el sitio puede cargar Google Analytics 4 para medir uso agregado y mejorar contenidos. Si se habilita publicidad, el sitio puede preparar la carga de Google AdSense respetando la separación entre contenido y anuncios.</p>
            <p>Mientras no exista consentimiento válido, estas tecnologías no deberían cargarse desde la configuración pública del sitio. Además, si se utilizan anuncios personalizados en el Espacio Económico Europeo, el responsable debe completar la capa de gestión del consentimiento exigida por Google para ese entorno.</p>
          </section>
          <section>
            <h2>Cómo gestionar o revocar el consentimiento</h2>
            <p>El usuario puede aceptar o rechazar cookies analíticas y publicitarias desde el banner mostrado en la navegación inicial. También puede borrar cookies desde su navegador o impedir su almacenamiento mediante la configuración disponible en cada aplicación o dispositivo.</p>
            <p>La eliminación o bloqueo de determinadas cookies puede afectar a funciones no esenciales del sitio, pero no debería impedir el acceso al contenido informativo básico.</p>
          </section>
        </div>
      </article>
      <aside class="content-sidebar">
        <p class="eyebrow">Cookies previstas</p>
        <ul>
          <li>Técnicas de consentimiento y navegación.</li>
          <li>Analíticas, solo con aceptación expresa.</li>
          <li>Publicitarias, solo con aceptación expresa.</li>
          <li>Más información en <a href="politica-privacidad.html">privacidad</a>.</li>
        </ul>
      </aside>
    </div>
  </section>
</main>
"@
  }
  [ordered]@{
    Path = 'legal/terminos-condiciones.html'
    Title = 'Condiciones de uso'
    Description = 'Reglas básicas de acceso, uso del contenido, enlaces externos y limitaciones del servicio.'
    Main = @"
<main id="main-content">
  <section class="page-hero">
    <div class="container">
      <div class="panel page-hero-copy">
        <p class="breadcrumbs"><a href="../index.html">Inicio</a> / Condiciones de uso</p>
        <p class="eyebrow accent">Uso del sitio</p>
        <h1>Condiciones de uso</h1>
        <p class="content-lead">Estas condiciones regulan el acceso y uso del sitio web, así como las limitaciones propias de un servicio de información y orientación no personalizada.</p>
      </div>
    </div>
  </section>
  <section class="section">
    <div class="container content-layout">
      <article class="panel content-main">
        <div class="content-body">
          <section>
            <h2>Naturaleza del contenido</h2>
            <p>Los contenidos del sitio tienen finalidad informativa y divulgativa. Se publican para ayudar a entender mejor cuestiones relacionadas con ASNEF, deuda, solvencia y reclamaciones, pero no constituyen dictamen profesional individual ni garantía de resultado en un expediente concreto.</p>
          </section>
          <section>
            <h2>Obligaciones del usuario</h2>
            <p>El usuario se compromete a utilizar el sitio y sus formularios de buena fe, a facilitar información veraz cuando contacte y a no usar la plataforma para actividades ilícitas, suplantaciones, envíos automatizados o intentos de acceso no autorizado.</p>
          </section>
          <section>
            <h2>Disponibilidad, enlaces y cambios</h2>
            <p>El responsable intenta mantener el sitio disponible y actualizado, pero no garantiza continuidad absoluta, ausencia de interrupciones o la permanencia indefinida de todos los contenidos. La web puede enlazar a recursos de terceros con fines informativos, sin asumir por ello control permanente ni responsabilidad sobre su contenido.</p>
            <p>El responsable puede modificar la estructura, diseño, textos y funcionalidades del sitio para mejorar la experiencia, adaptarse a cambios normativos o reforzar la seguridad.</p>
          </section>
          <section>
            <h2>Limitación de responsabilidad</h2>
            <p>El usuario es responsable del uso que haga de la información publicada. Cualquier decisión económica, jurídica o contractual relevante debería valorarse con la profundidad necesaria para el caso concreto. El responsable no responde por perjuicios derivados de decisiones adoptadas únicamente con base en una lectura general del sitio.</p>
          </section>
        </div>
      </article>
      <aside class="content-sidebar">
        <p class="eyebrow">Accesos relacionados</p>
        <ul>
          <li><a href="aviso-legal.html">Aviso legal</a></li>
          <li><a href="politica-privacidad.html">Privacidad</a></li>
          <li><a href="../pages/contacto.html">Contacto</a></li>
        </ul>
      </aside>
    </div>
  </section>
</main>
"@
  }
)

foreach ($page in $legalPages) {
  Write-Utf8NoBom -Path (Join-Path $root $page.Path) -Content (
    Page-Shell -RelativePath $page.Path -BodyClass 'theme-home page-legal' -Title "$($page.Title) | $($site.Name)" -Description $page.Description -ActiveKey '' -MainContent $page.Main -JsonLdBlocks @(
      (Organization-JsonLd),
      (Breadcrumb-JsonLd @(
        @{ label = 'Inicio'; href = '../index.html'; absolute = $site.Url },
        @{ label = $page.Title; href = ''; absolute = (Join-Url $page.Path) }
      ))
    )
  )
}

$errorMain = '<main id="main-content"><section class="hero"><div class="container hero-grid"><div class="panel hero-copy"><p class="eyebrow accent">Error 404</p><h1>La página que buscas ya no está disponible.</h1><div class="hero-actions"><a class="button button-primary" href="index.html">Ir al inicio</a><a class="button button-secondary" href="articulos/index.html">Ver artículos</a></div></div></div></section></main>'
Write-Utf8NoBom -Path (Join-Path $root '404.html') -Content (Page-Shell -RelativePath '404.html' -BodyClass 'theme-home page-error' -Title 'Página no encontrada | Solución ASNEF' -Description 'Página no encontrada. Vuelve al inicio o entra en el centro editorial.' -ActiveKey 'home' -MainContent $errorMain -Robots 'noindex, follow' -JsonLdBlocks @((Organization-JsonLd)))

$publicPages = @(
  'index.html',
  'pages/sobre-nosotros.html',
  'pages/contacto.html',
  'pages/salir-de-asnef.html',
  'pages/consultar-asnef.html',
  'pages/derechos-usuario.html',
  'articulos/index.html',
  'legal/aviso-legal.html',
  'legal/politica-privacidad.html',
  'legal/politica-cookies.html',
  'legal/terminos-condiciones.html'
)
$publicPages += ($legacyGuideEntries | ForEach-Object { $_.Path })
$publicPages += ($blogEntries | ForEach-Object { $_.Path })

$sitemapLines = foreach ($page in $publicPages) {
  $loc = if ($page -eq 'index.html') { $site.Url } else { Join-Url $page }
  "  <url><loc>$loc</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>"
}

Write-Utf8NoBom -Path (Join-Path $root 'sitemap.xml') -Content ("<?xml version=""1.0"" encoding=""UTF-8""?><urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">" + ($sitemapLines -join '') + '</urlset>')
Write-Utf8NoBom -Path (Join-Path $root 'robots.txt') -Content ("User-agent: *`nAllow: /`nDisallow: /admin/`nDisallow: /cuenta/`n`nSitemap: $($site.Url)/sitemap.xml")
