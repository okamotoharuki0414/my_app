export interface HeroData {
  id: string
  industry: string
  companyName: string
  mainCopy: string
  subCopy: string
  ctaText: string
  backgroundImage: string
  logoText: string
  colorScheme: 'dark' | 'light' | 'colorful'
  layout: 'left' | 'center' | 'right'
}