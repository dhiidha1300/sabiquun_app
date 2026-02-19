import Link from 'next/link'
import Image from 'next/image'
import { Button } from '@/components/ui/button'
import { Download, Apple, Smartphone } from 'lucide-react'

export function CTA() {
  return (
    <section id="download" className="py-20 sm:py-32 bg-primary text-primary-foreground">
      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
            Ready to Transform Your Daily Worship?
          </h2>
          <p className="mt-4 text-lg opacity-90">
            Join thousands of Muslims who have made Sabiquun part of their daily routine.
            Download the app today and start your journey to consistent spiritual growth.
          </p>

          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-6">
            {/* App Store Badge */}
            <Link
              href={process.env.NEXT_PUBLIC_APP_STORE_URL || '#'}
              className="block transition-transform hover:scale-105"
            >
              <Image
                src="/assets/images/app-store/badge.png"
                alt="Download on the App Store"
                width={180}
                height={60}
                className="h-14 w-auto"
                priority
              />
            </Link>

            {/* Play Store Badge */}
            <Link
              href={process.env.NEXT_PUBLIC_PLAY_STORE_URL || '#'}
              className="block transition-transform hover:scale-105"
            >
              <Image
                src="/assets/images/play-store/badge.png"
                alt="Get it on Google Play"
                width={202}
                height={60}
                className="h-14 w-auto"
                priority
              />
            </Link>
          </div>

          {/* Additional info */}
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-6 text-sm opacity-80">
            <div className="flex items-center gap-2">
              <Download className="h-4 w-4" />
              <span>Free Download</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 bg-green-400 rounded-full" />
              <span>No Credit Card Required</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 bg-green-400 rounded-full" />
              <span>30-Day Free Trial</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
