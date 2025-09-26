'use client'

import { useParams } from 'next/navigation'
import { heroData } from '@/data/heroData'
import HeroSection from '@/components/HeroSection'
import Link from 'next/link'

export default function IndustryPage() {
  const params = useParams()
  const industry = params.industry as string
  
  const hero = heroData.find(h => h.id === industry)
  
  if (!hero) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
        <div className="text-center">
          <h1 className="text-4xl font-bold mb-4">業界が見つかりません</h1>
          <Link href="/" className="text-blue-400 hover:text-blue-300">
            トップページに戻る
          </Link>
        </div>
      </div>
    )
  }

  return (
    <main className="relative">
      <HeroSection data={hero} />
      
      {/* Back Button */}
      <div className="fixed top-8 left-8 z-20">
        <Link
          href="/"
          className="w-12 h-12 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-all duration-200 shadow-lg"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </Link>
      </div>
    </main>
  )
}