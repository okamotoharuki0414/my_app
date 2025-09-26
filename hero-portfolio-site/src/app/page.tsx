'use client'

import { useState, useEffect } from 'react'
import { heroData } from '@/data/heroData'
import HeroSection from '@/components/HeroSection'

export default function Home() {
  const [currentIndex, setCurrentIndex] = useState(0)
  const currentHero = heroData[currentIndex]

  const nextHero = () => {
    setCurrentIndex((prev) => (prev + 1) % heroData.length)
  }

  const prevHero = () => {
    setCurrentIndex((prev) => (prev - 1 + heroData.length) % heroData.length)
  }

  const goToHero = (index: number) => {
    setCurrentIndex(index)
  }

  // Keyboard navigation
  useEffect(() => {
    const handleKeyPress = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') {
        prevHero()
      } else if (event.key === 'ArrowRight') {
        nextHero()
      } else if (event.key >= '1' && event.key <= '9') {
        const index = parseInt(event.key) - 1
        if (index < heroData.length) {
          goToHero(index)
        }
      }
    }

    window.addEventListener('keydown', handleKeyPress)
    return () => window.removeEventListener('keydown', handleKeyPress)
  }, [])

  return (
    <main className="relative">
      <HeroSection data={currentHero} />

      {/* Navigation Controls */}
      <div className="fixed top-1/2 left-8 transform -translate-y-1/2 z-20">
        <button
          onClick={prevHero}
          className="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-all duration-200 shadow-lg"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </button>
      </div>


    </main>
  )
}