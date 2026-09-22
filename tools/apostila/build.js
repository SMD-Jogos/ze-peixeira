const fs = require('fs');
const path = require('path');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType, Table, TableRow, TableCell,
  WidthType, ShadingType, BorderStyle, LevelFormat, ExternalHyperlink, Header, Footer, PageNumber,
  TableOfContents, PageBreak, TabStopType, Tab,
} = require('docx');

// Uso (na raiz do repositório): npm install --prefix tools/apostila && node tools/apostila/build.js
const REPO = path.resolve(__dirname, '..', '..');
const OUT = process.argv[2] || path.join(REPO, 'docs', 'apostila-sdd-ze-peixeira.docx');

// ---------- identidade visual ----------
const F_TIT = 'Georgia';
const F_TXT = 'Arial';
const F_MONO = 'Consolas';
const TINTA = '1F1F1F';
const ACENTO = '7A1F2B';      // bordô
const CINZA = '5F5F5F';
const FUNDO_COD = 'F4F1EC';   // off-white quente
const FUNDO_NOTA = 'F7EEEE';
const FUNDO_TAB = 'EFE9E1';
const LINHA = 'C9C2B8';
const LARGURA = 9638;         // A4 com margens de 2 cm

// ---------- inline ----------
function inline(text, base = {}) {
  const out = [];
  const re = /(\*\*[^*]+?\*\*|`[^`]+`|\[[^\]]+\]\([^)]+\)|\*[^*\s][^*]*?\*)/g;
  let last = 0, m;
  while ((m = re.exec(text)) !== null) {
    if (m.index > last) out.push(new TextRun({ text: text.slice(last, m.index), ...base }));
    const t = m[0];
    if (t.startsWith('**')) out.push(...inline(t.slice(2, -2), { ...base, bold: true }));
    else if (t.startsWith('`')) out.push(new TextRun({ text: t.slice(1, -1), ...base, font: F_MONO, size: (base.size || 21) - 2, color: ACENTO }));
    else if (t.startsWith('[')) {
      const mm = t.match(/\[([^\]]+)\]\(([^)]+)\)/);
      const url = mm[2];
      if (/^https?:/.test(url)) {
        out.push(new ExternalHyperlink({ link: url, children: [new TextRun({ text: mm[1], ...base, style: 'Hyperlink' })] }));
      } else {
        out.push(...inline(mm[1], base));
      }
    } else out.push(...inline(t.slice(1, -1), { ...base, italics: true }));
    last = m.index + t.length;
  }
  if (last < text.length) out.push(new TextRun({ text: text.slice(last), ...base }));
  return out;
}

// ---------- blocos ----------
function codeBlock(lines) {
  return lines.map((l, i) => new Paragraph({
    children: [new TextRun({ text: l.length ? l : ' ', font: F_MONO, size: 18, color: TINTA })],
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: FUNDO_COD },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: ACENTO, space: 8 } },
    spacing: { before: i === 0 ? 120 : 0, after: i === lines.length - 1 ? 160 : 0, line: 260 },
    indent: { left: 200, right: 200 },
    keepLines: true, keepNext: i < lines.length - 1,
  }));
}

function nota(text) {
  return new Paragraph({
    children: inline(text, { size: 20 }),
    shading: { type: ShadingType.CLEAR, color: 'auto', fill: FUNDO_NOTA },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: ACENTO, space: 8 } },
    spacing: { before: 120, after: 160, line: 300 },
    indent: { left: 200, right: 200 },
  });
}

function splitRow(line) {
  let s = line.trim();
  if (s.startsWith('|')) s = s.slice(1);
  if (s.endsWith('|')) s = s.slice(0, -1);
  return s.split('|').map(c => c.trim());
}

function table(rows) {
  const header = splitRow(rows[0]);
  const body = rows.slice(2).map(splitRow);
  const n = header.length;
  const lens = header.map((h, i) => Math.max(h.length, ...body.map(r => (r[i] || '').replace(/[`*]/g, '').length)));
  const w = lens.map((l, i) => Math.min(Math.max(l, header[i].length + 2, 10), 60));
  const tot = w.reduce((a, b) => a + b, 0);
  const cols = w.map(x => Math.floor(x / tot * LARGURA));
  cols[n - 1] += LARGURA - cols.reduce((a, b) => a + b, 0);
  for (let k = 0; k < n; k++) {
    if (cols[k] < 1150) { const falta = 1150 - cols[k]; const j = cols.indexOf(Math.max(...cols)); cols[j] -= falta; cols[k] = 1150; }
  }
  const borda = { style: BorderStyle.SINGLE, size: 4, color: LINHA };
  const borders = { top: borda, bottom: borda, left: borda, right: borda };
  const cell = (txt, i, head) => new TableCell({
    width: { size: cols[i], type: WidthType.DXA },
    borders,
    shading: head ? { type: ShadingType.CLEAR, color: 'auto', fill: FUNDO_TAB } : undefined,
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    children: [new Paragraph({ children: inline(txt || '', { size: 19, bold: head || undefined }), spacing: { before: 0, after: 0, line: 270 } })],
  });
  return [
    new Table({
      width: { size: LARGURA, type: WidthType.DXA },
      columnWidths: cols,
      rows: [
        new TableRow({ tableHeader: true, children: header.map((h, i) => cell(h, i, true)) }),
        ...body.map(r => new TableRow({ cantSplit: true, children: header.map((_, i) => cell(r[i], i, false)) })),
      ],
    }),
    new Paragraph({ children: [], spacing: { before: 0, after: 120 } }),
  ];
}

let numInstance = 0;
function parse(md, { shift = 0, skipTitle = false, titleOverride = null } = {}) {
  const lines = md.split('\n');
  const out = [];
  let i = 0;
  let listInst = null; let lastWasList = false;
  const H = [HeadingLevel.HEADING_1, HeadingLevel.HEADING_2, HeadingLevel.HEADING_3, HeadingLevel.HEADING_4];
  while (i < lines.length) {
    let line = lines[i];
    const trimmed = line.trim();
    // code fence
    if (trimmed.startsWith('```')) {
      const buf = []; const ind = line.indexOf('```');
      i++;
      while (i < lines.length && !lines[i].trim().startsWith('```')) { buf.push(lines[i].slice(Math.min(ind, lines[i].search(/\S|$/)))); i++; }
      i++; out.push(...codeBlock(buf)); continue;
    }
    if (!trimmed) { i++; lastWasList = lastWasList && (i < lines.length && (/^\s*(-|\d+\.)\s/.test(lines[i]) || /^\s{2,}\S/.test(lines[i]) || !lines[i].trim())); continue; }
    const h = trimmed.match(/^(#{1,4})\s+(.*)$/);
    if (h) {
      let lvl = h[1].length;
      if (lvl === 1 && skipTitle) { i++; continue; }
      const text = (lvl === 1 && titleOverride) ? titleOverride : h[2];
      lvl = Math.min(lvl - 1 + shift, 3);
      if (lvl < 0) lvl = 0;
      out.push(new Paragraph({ heading: H[lvl], children: inline(text.replace(/\*\*/g, '')) }));
      i++; lastWasList = false; continue;
    }
    if (trimmed.startsWith('|')) {
      const rows = [];
      while (i < lines.length && lines[i].trim().startsWith('|')) { rows.push(lines[i]); i++; }
      out.push(...table(rows)); lastWasList = false; continue;
    }
    if (trimmed.startsWith('>')) {
      const buf = [];
      while (i < lines.length && lines[i].trim().startsWith('>')) { buf.push(lines[i].trim().replace(/^>\s?/, '')); i++; }
      out.push(nota(buf.join(' '))); lastWasList = false; continue;
    }
    const li = line.match(/^(\s*)(-|\d+\.)\s+(.*)$/);
    if (li) {
      const level = li[1].length >= 2 ? 1 : 0;
      const ordered = /\d/.test(li[2]);
      let text = li[3];
      let ref;
      if (/^\[[ x]\]\s/.test(text)) { ref = 'check'; text = text.slice(4); }
      else ref = ordered ? 'num' : 'bul';
      if (ordered && level === 0 && !lastWasList) { numInstance++; listInst = numInstance; }
      if (!lastWasList && !ordered) { numInstance++; listInst = numInstance; }
      // continuation lines
      i++;
      while (i < lines.length && lines[i].trim() && !/^\s*(-|\d+\.)\s/.test(lines[i]) && !lines[i].trim().startsWith('```') && /^\s{2,}/.test(lines[i])) { text += ' ' + lines[i].trim(); i++; }
      out.push(new Paragraph({
        numbering: { reference: ref, level, instance: ref === 'num' ? listInst : undefined },
        children: inline(text), spacing: { before: 40, after: 40, line: 300 },
      }));
      lastWasList = true; continue;
    }
    // paragraph
    const buf = [trimmed]; i++;
    while (i < lines.length && lines[i].trim() && !/^(#|\||>|```|\s*(-|\d+\.)\s)/.test(lines[i].trim())) { buf.push(lines[i].trim()); i++; }
    out.push(new Paragraph({ children: inline(buf.join(' ')), spacing: { before: 60, after: 140, line: 312 }, alignment: AlignmentType.JUSTIFIED }));
    lastWasList = false;
  }
  return out;
}

// ---------- conteúdo ----------
const read = p => fs.readFileSync(path.join(REPO, p), 'utf8');
let fluxo = read('docs/fluxo-sdd.md');
// a primeira linha (título) vai para a capa; o parágrafo de abertura vira "Apresentação"
fluxo = fluxo.replace(/^# .*\n/, '');
fluxo = fluxo.replace('## 1. Sobre este material', '## 1. Sobre esta apostila');
fluxo = fluxo.replace('│   ├── fluxo-sdd.md                 # este documento', '│   ├── fluxo-sdd.md                 # o fluxo (conteúdo desta apostila)');
const [intro, ...resto] = fluxo.split('\n## ');
const corpo = '## ' + resto.join('\n## ');

const capa = [
  new Paragraph({ children: [], spacing: { before: 2400 } }),
  new Paragraph({ children: [new TextRun({ text: 'PROGRAMAÇÃO PARA JOGOS I', font: F_TXT, size: 20, bold: true, color: ACENTO, characterSpacing: 40 })], spacing: { after: 400 } }),
  new Paragraph({ children: [new TextRun({ text: 'Desenvolvimento de jogos guiado por especificação', font: F_TIT, size: 52, color: TINTA })], spacing: { after: 360 } }),
  new Paragraph({ children: [new TextRun({ text: 'Um fluxo SDD com agentes de IA, demonstrado no Godot 4 com o caso Zé Peixeira', font: F_TIT, size: 28, italics: true, color: CINZA })], spacing: { after: 2400 } }),
  new Paragraph({ children: [new TextRun({ text: 'Material complementar', font: F_TXT, size: 21, color: CINZA })], spacing: { after: 60 } }),
  new Paragraph({ children: [new TextRun({ text: 'Sistemas e Mídias Digitais · Universidade Federal do Ceará', font: F_TXT, size: 21, color: CINZA })], spacing: { after: 60 } }),
  new Paragraph({ children: [new TextRun({ text: '2026.2', font: F_TXT, size: 21, color: CINZA })] }),
  new Paragraph({ children: [new PageBreak()] }),
];

const sumario = [
  new Paragraph({ children: [new TextRun({ text: 'Sumário', font: F_TIT, size: 36, color: TINTA })], spacing: { after: 240 } }),
  new TableOfContents('Sumário', { hyperlink: true, headingStyleRange: '1-2' }),
  new Paragraph({ children: [new PageBreak()] }),
];

const apresentacao = [
  new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun('Apresentação')] }),
  ...parse(intro.trim()),
];

const quebra = () => new Paragraph({ children: [new PageBreak()] });
const apendices = [
  quebra(),
  ...parse(read('.specify/memory/constitution.md'), { titleOverride: 'Apêndice A — Constituição do projeto Zé Peixeira' }),
  quebra(),
  new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun('Apêndice B — Exemplo de especificação: o pulo')] }),
  new Paragraph({ children: inline('Especificação completa da fatia 002, como está em `specs/002-pulo/spec.md`. As demais fatias seguem a mesma estrutura e estão no repositório.'), spacing: { after: 160, line: 312 } }),
  ...parse(read('specs/002-pulo/spec.md'), { skipTitle: true, shift: 0 }),
  quebra(),
  ...parse(read('docs/checklists/revisao-tarefa.md'), { titleOverride: 'Apêndice C — Checklist de revisão de tarefa' }),
  quebra(),
  ...parse(read('docs/review/_modelo.md'), { titleOverride: 'Apêndice D — Modelo de registro de revisão' }),
];

// ---------- documento ----------
const doc = new Document({
  creator: 'Programação para Jogos I — SMD/UFC',
  title: 'Desenvolvimento de jogos guiado por especificação com agentes de IA',
  features: { updateFields: true },
  styles: {
    default: { document: { run: { font: F_TXT, size: 21, color: TINTA } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: F_TIT, size: 34, color: TINTA },
        paragraph: { spacing: { before: 480, after: 200 }, outlineLevel: 0, keepNext: true } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: F_TIT, size: 27, color: ACENTO },
        paragraph: { spacing: { before: 360, after: 140 }, outlineLevel: 1, keepNext: true } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: F_TXT, size: 22, bold: true, color: TINTA },
        paragraph: { spacing: { before: 280, after: 100 }, outlineLevel: 2, keepNext: true } },
      { id: 'Heading4', name: 'Heading 4', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: F_TXT, size: 21, bold: true, color: CINZA },
        paragraph: { spacing: { before: 200, after: 80 }, outlineLevel: 3, keepNext: true } },
    ],
    characterStyles: [
      { id: 'Hyperlink', name: 'Hyperlink', run: { color: ACENTO, underline: {} } },
    ],
  },
  numbering: {
    config: [
      { reference: 'bul', levels: [
        { level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 270 } } } },
        { level: 1, format: LevelFormat.BULLET, text: '–', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1080, hanging: 270 } } } } ] },
      { reference: 'num', levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: '%1.', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 360 } } } },
        { level: 1, format: LevelFormat.LOWER_LETTER, text: '%2)', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1080, hanging: 360 } } } } ] },
      { reference: 'check', levels: [
        { level: 0, format: LevelFormat.BULLET, text: '☐', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 540, hanging: 330 } } } },
        { level: 1, format: LevelFormat.BULLET, text: '☐', alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 1080, hanging: 330 } } } } ] },
    ],
  },
  sections: [
    {
      properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, bottom: 1134, left: 1134, right: 1134 } }, titlePage: true },
      headers: {
        default: new Header({ children: [new Paragraph({
          tabStops: [{ type: TabStopType.RIGHT, position: LARGURA }],
          children: [
            new TextRun({ text: 'Programação para Jogos I', font: F_TXT, size: 16, color: CINZA }),
            new TextRun({ children: [new Tab(), 'SDD com agentes de IA'], font: F_TXT, size: 16, color: CINZA }),
          ] })] }),
        first: new Header({ children: [new Paragraph({ children: [] })] }),
      },
      footers: {
        default: new Footer({ children: [new Paragraph({ alignment: AlignmentType.RIGHT,
          children: [new TextRun({ children: [PageNumber.CURRENT], font: F_TXT, size: 18, color: CINZA })] })] }),
        first: new Footer({ children: [new Paragraph({ children: [] })] }),
      },
      children: [...capa, ...sumario, ...apresentacao, ...parse(corpo), ...apendices],
    },
  ],
});

Packer.toBuffer(doc).then(b => { fs.writeFileSync(OUT, b); console.log('ok', OUT); });
