'use client'

import { HeroData } from '@/types/hero'
import Image from 'next/image'
import { motion } from 'framer-motion'

interface HeroSectionProps {
  data: HeroData
}

export default function HeroSection({ data }: HeroSectionProps) {
  const {
    companyName,
    mainCopy,
    subCopy,
    ctaText,
    backgroundImage,
    logoText,
    colorScheme,
    layout
  } = data

  const getTextColor = () => {
    switch (colorScheme) {
      case 'light': return 'text-slate-800'
      case 'dark': return 'text-white'
      case 'colorful': return 'text-slate-800'
      default: return 'text-white'
    }
  }

  const getOverlayColor = () => {
    switch (colorScheme) {
      case 'light': return 'from-white/70 via-white/50 to-white/30'
      case 'dark': return 'from-black/60 via-black/40 to-black/20'
      case 'colorful': return 'from-purple-900/30 via-blue-900/20 to-transparent'
      default: return 'from-black/60 via-black/40 to-black/20'
    }
  }

  const getButtonStyle = () => {
    switch (colorScheme) {
      case 'light': 
        return 'bg-slate-800 hover:bg-slate-900 text-white border-slate-800'
      case 'dark': 
        return 'bg-white hover:bg-gray-100 text-slate-800 border-white'
      case 'colorful': 
        return 'bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white border-transparent'
      default: 
        return 'bg-white hover:bg-gray-100 text-slate-800 border-white'
    }
  }

  const getContentAlignment = () => {
    switch (layout) {
      case 'left': return 'justify-start text-left'
      case 'center': return 'justify-center text-center'
      case 'right': return 'justify-end text-right'
      default: return 'justify-center text-center'
    }
  }

  const getIndustrySpecificStyles = () => {
    switch (data.id) {
      case 'corporate-it':
        return {
          mainCopyClass: 'font-mono tracking-wider text-corporate-glow',
          subCopyClass: 'font-light tracking-wide',
          logoClass: 'font-mono tracking-widest text-corporate-glow',
          buttonClass: 'btn-corporate',
          textShadow: 'drop-shadow-lg'
        }
      case 'manufacturing':
        return {
          mainCopyClass: 'font-black tracking-tight text-manufacturing-bold',
          subCopyClass: 'font-medium',
          logoClass: 'font-black tracking-tight text-manufacturing-bold',
          buttonClass: 'btn-manufacturing',
          textShadow: 'drop-shadow-2xl'
        }
      case 'medical':
        return {
          mainCopyClass: 'font-light tracking-wide text-medical-soft',
          subCopyClass: 'font-extralight',
          logoClass: 'font-light tracking-wide text-medical-soft',
          buttonClass: '',
          textShadow: 'drop-shadow-sm'
        }
      case 'ec-fashion':
        return {
          mainCopyClass: 'font-bold italic tracking-normal text-fashion-gradient',
          subCopyClass: 'font-normal italic',
          logoClass: 'font-bold italic text-fashion-gradient',
          buttonClass: '',
          textShadow: 'drop-shadow-md'
        }
      case 'restaurant':
        return {
          mainCopyClass: 'font-serif font-bold tracking-wide text-restaurant-elegant',
          subCopyClass: 'font-serif font-light',
          logoClass: 'font-serif font-bold text-restaurant-elegant',
          buttonClass: '',
          textShadow: 'drop-shadow-xl'
        }
      case 'beauty':
        return {
          mainCopyClass: 'font-extralight tracking-widest text-beauty-delicate',
          subCopyClass: 'font-thin tracking-wide',
          logoClass: 'font-thin tracking-widest text-beauty-delicate',
          buttonClass: '',
          textShadow: 'drop-shadow-sm'
        }
      case 'real-estate':
        return {
          mainCopyClass: 'font-bold tracking-tight uppercase text-realestate-strong',
          subCopyClass: 'font-medium tracking-normal',
          logoClass: 'font-bold tracking-wide uppercase text-realestate-strong',
          buttonClass: '',
          textShadow: 'drop-shadow-2xl'
        }
      case 'saas':
        return {
          mainCopyClass: 'font-semibold tracking-normal text-saas-modern',
          subCopyClass: 'font-light tracking-wide',
          logoClass: 'font-bold tracking-normal text-saas-modern',
          buttonClass: '',
          textShadow: 'drop-shadow-lg'
        }
      case 'recruitment':
        return {
          mainCopyClass: 'font-medium tracking-wide text-recruitment-warm',
          subCopyClass: 'font-normal tracking-normal',
          logoClass: 'font-medium tracking-wide text-recruitment-warm',
          buttonClass: '',
          textShadow: 'drop-shadow-md'
        }
      default:
        return {
          mainCopyClass: 'font-black',
          subCopyClass: 'font-light',
          logoClass: 'font-bold',
          buttonClass: '',
          textShadow: 'drop-shadow-lg'
        }
    }
  }

  const styles = getIndustrySpecificStyles()

  return (
    <div className="relative min-h-screen w-full overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0">
        <Image
          src={backgroundImage}
          alt={`${companyName} background`}
          fill
          className="object-cover"
          priority
        />
        {/* Overlay */}
        <div className={`absolute inset-0 bg-gradient-to-br ${getOverlayColor()}`} />
      </div>

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col">
        {/* Header/Logo */}
        <header className="p-8 lg:p-12">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className={`text-2xl lg:text-3xl ${styles.logoClass} ${getTextColor()}`}
          >
            {logoText}
          </motion.div>
        </header>

        {/* Main Content */}
        <div className={`flex-1 flex items-center px-8 lg:px-12 ${getContentAlignment()}`}>
          <div className="max-w-4xl">
            <motion.h1
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className={`text-4xl lg:text-6xl xl:text-7xl ${styles.mainCopyClass} mb-6 lg:mb-8 leading-tight ${getTextColor()}`}
            >
              {mainCopy}
            </motion.h1>
            
            <motion.p
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className={`text-lg lg:text-xl xl:text-2xl mb-10 lg:mb-12 ${styles.subCopyClass} leading-relaxed ${getTextColor()} opacity-90`}
            >
              {subCopy}
            </motion.p>

            <motion.button
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.6 }}
              className={`
                inline-flex items-center px-8 lg:px-12 py-4 lg:py-5 
                rounded-full text-lg lg:text-xl font-semibold 
                transition-all duration-300 transform hover:scale-105 
                shadow-lg hover:shadow-xl border-2
                ${getButtonStyle()} ${styles.buttonClass}
              `}
            >
              {ctaText}
              <svg 
                className="ml-3 w-5 h-5 lg:w-6 lg:h-6" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path 
                  strokeLinecap="round" 
                  strokeLinejoin="round" 
                  strokeWidth={2} 
                  d="M17 8l4 4m0 0l-4 4m4-4H3" 
                />
              </svg>
            </motion.button>
          </div>
        </div>

        {/* Bottom Indicator */}
        <div className="p-8 lg:p-12 flex justify-center">
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 1, delay: 1 }}
            className={`text-sm ${getTextColor()} opacity-60`}
          >
            {data.industry}
          </motion.div>
        </div>
      </div>
    </div>
  )
}