export function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

export function formatCategory(category) {
  const categories = {
    '电子产品': 'Electronics',
    '证件': 'ID Card',
    '书籍': 'Books',
    '衣物': 'Clothing',
    '饰品': 'Accessories',
    '文具': 'Stationery',
    '其他': 'Other'
  }
  return categories[category] || category
}

export function formatStatus(status) {
  const statusMap = {
    'PENDING': '待审核',
    'APPROVED': '已发布',
    'REJECTED': '审核未通过',
    'FOUND_BACK': '已找到',
    'RETURNED': '已归还',
    'EXPIRED': '已过期',
    'CLOSED': '已关闭'
  }
  return statusMap[status] || status
}

export function formatType(type) {
  return type === 'LOST' ? '寻物' : '招领'
}

export function getStatusColor(status) {
  const colorMap = {
    'PENDING': 'warning',
    'APPROVED': 'success',
    'REJECTED': 'danger',
    'FOUND_BACK': 'success',
    'RETURNED': 'success',
    'EXPIRED': 'danger',
    'CLOSED': 'info'
  }
  return colorMap[status] || 'default'
}

export function getTypeColor(type) {
  return type === 'LOST' ? 'danger' : 'success'
}

export function truncateText(text, maxLength = 50) {
  if (!text) return ''
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

export function formatCompletionTargetStatus(status) {
  const targetMap = {
    'FOUND_BACK': '已找到',
    'RETURNED': '已归还'
  }
  return targetMap[status] || status
}

export function buildPlaceholderImage(item) {
  const typeLabel = item?.type === 'LOST' ? '寻物启示' : '失物招领'
  const categoryLabel = item?.category || '校园物品'
  const titleLabel = (item?.title || '校园失物招领').slice(0, 18)
  const accent = item?.type === 'LOST' ? '#ef4444' : '#2563eb'
  const bg0 = item?.type === 'LOST' ? '#fff1f2' : '#eff6ff'
  const bg1 = item?.type === 'LOST' ? '#ffe4e6' : '#dbeafe'

  const iconByCategory = (category) => {
    const key = category || ''
    if (key.includes('证件')) return 'doc'
    if (key.includes('电子') || key.includes('手机') || key.includes('笔记本')) return 'phone'
    if (key.includes('书')) return 'book'
    if (key.includes('衣')) return 'shirt'
    if (key.includes('饰') || key.includes('首饰')) return 'ring'
    if (key.includes('文具')) return 'pencil'
    return 'box'
  }

  const icon = iconByCategory(categoryLabel)
  const icons = {
    phone: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <rect x="0" y="0" width="120" height="180" rx="26" />
      <line x1="38" y1="26" x2="82" y2="26" />
      <circle cx="60" cy="150" r="10" fill="${accent}" stroke="none" />
    </g>`,
    doc: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <rect x="0" y="16" width="160" height="130" rx="18" />
      <circle cx="52" cy="78" r="20" />
      <line x1="92" y1="62" x2="138" y2="62" />
      <line x1="92" y1="94" x2="138" y2="94" />
    </g>`,
    book: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <path d="M12 24h92c18 0 32 14 32 32v132c-10-10-24-16-40-16H12V24z" />
      <path d="M148 24h92c18 0 32 14 32 32v132c-10-10-24-16-40-16h-52V24z" transform="translate(-12 0)" />
      <line x1="56" y1="70" x2="112" y2="70" />
    </g>`,
    shirt: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <path d="M36 44l24-20h56l24 20 26 26-28 24v84H38V94L10 70 36 44z" />
      <path d="M78 24l10 18h-20l10-18z" fill="${accent}" stroke="none" opacity="0.25" />
    </g>`,
    ring: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <path d="M80 22l18 26-18 18-18-18 18-26z" />
      <circle cx="80" cy="120" r="50" />
      <path d="M42 84c20 18 56 18 76 0" opacity="0.6" />
    </g>`,
    pencil: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <path d="M24 154l16 16 110-110-16-16L24 154z" />
      <path d="M18 182l36-10-26-26-10 36z" fill="${accent}" stroke="none" opacity="0.25" />
      <line x1="120" y1="58" x2="146" y2="84" />
    </g>`,
    box: `<g fill="none" stroke="${accent}" stroke-width="10" stroke-linejoin="round" stroke-linecap="round">
      <path d="M24 64l56-32 56 32v96l-56 32-56-32V64z" />
      <line x1="24" y1="64" x2="136" y2="64" />
      <line x1="80" y1="32" x2="80" y2="192" />
    </g>`
  }

  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="640" height="400" viewBox="0 0 640 400">
      <defs>
        <linearGradient id="bg" x1="0" x2="1" y1="0" y2="1">
          <stop offset="0%" stop-color="${bg0}"/>
          <stop offset="100%" stop-color="${bg1}"/>
        </linearGradient>
        <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
          <feDropShadow dx="0" dy="18" stdDeviation="18" flood-color="rgba(15,23,42,0.14)" />
        </filter>
      </defs>
      <rect width="640" height="400" rx="28" fill="url(#bg)"/>
      <rect x="44" y="44" width="552" height="312" rx="26" fill="rgba(255,255,255,0.86)" stroke="rgba(15,23,42,0.08)" filter="url(#shadow)"/>

      <g transform="translate(84 92)">
        ${icons[icon]}
      </g>

      <rect x="256" y="88" rx="999" ry="999" width="120" height="38" fill="${accent}" opacity="0.12"/>
      <text x="316" y="113" text-anchor="middle" font-size="16" fill="${accent}" font-family="Arial, sans-serif">${typeLabel}</text>

      <text x="256" y="168" font-size="26" fill="#0f172a" font-weight="700" font-family="Arial, sans-serif">${titleLabel}</text>
      <text x="256" y="210" font-size="18" fill="rgba(15,23,42,0.62)" font-family="Arial, sans-serif">${categoryLabel}</text>
      <text x="256" y="270" font-size="16" fill="rgba(15,23,42,0.45)" font-family="Arial, sans-serif">未上传实拍图</text>
    </svg>
  `.trim()
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`
}
