import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ArrowRight, Download, Play } from 'lucide-react'

export function Hero() {
  return (
    <section className="relative overflow-hidden py-20 sm:py-32">
      {/* Background decoration */}
      <div className="absolute inset-0 -z-10 overflow-hidden">
        <div className="absolute left-1/2 top-0 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] rounded-full bg-primary/5 blur-3xl" />
        <div className="absolute right-0 bottom-0 translate-x-1/2 translate-y-1/2 w-[600px] h-[600px] rounded-full bg-primary/10 blur-3xl" />
      </div>

      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-4xl text-center">
          {/* Badge */}
          <Badge variant="secondary" className="mb-6">
            Join thousands of Muslims improving their daily worship
          </Badge>

          {/* Headline */}
          <h1 className="text-4xl font-bold tracking-tight text-foreground sm:text-5xl md:text-6xl lg:text-7xl">
            Track Your Daily Deeds,{' '}
            <span className="text-primary">Transform Your Life</span>
          </h1>

          {/* Subheadline */}
          <p className="mt-6 text-lg text-muted-foreground sm:text-xl max-w-2xl mx-auto">
            Sabiquun helps you stay accountable to your daily Islamic obligations.
            Track your prayers, good deeds, and build lasting spiritual habits with
            community support and financial accountability.
          </p>

          {/* CTA Buttons */}
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link href="#download">
              <Button size="lg" className="w-full sm:w-auto gap-2">
                <Download className="h-5 w-5" />
                Download Free App
              </Button>
            </Link>
            <Link href="#how-it-works">
              <Button size="lg" variant="outline" className="w-full sm:w-auto gap-2">
                <Play className="h-5 w-5" />
                See How It Works
              </Button>
            </Link>
          </div>

          {/* Trust indicators */}
          <div className="mt-12 flex flex-col sm:flex-row items-center justify-center gap-8 text-sm text-muted-foreground">
            <div className="flex items-center gap-2">
              <div className="flex -space-x-2">
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="w-8 h-8 rounded-full bg-primary/20 border-2 border-background flex items-center justify-center text-xs font-medium text-primary"
                  >
                    {String.fromCharCode(64 + i)}
                  </div>
                ))}
              </div>
              <span>1,000+ Active Members</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="flex">
                {[1, 2, 3, 4, 5].map((i) => (
                  <svg
                    key={i}
                    className="w-4 h-4 text-yellow-500 fill-current"
                    viewBox="0 0 20 20"
                  >
                    <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" />
                  </svg>
                ))}
              </div>
              <span>4.9 Star Rating</span>
            </div>
          </div>
        </div>

        {/* App Preview */}
        <div className="mt-16 relative mx-auto max-w-5xl">
          <div className="relative rounded-2xl bg-gradient-to-b from-primary/10 to-primary/5 p-4 sm:p-8">
            <div className="aspect-[16/9] rounded-xl bg-muted/50 border border-border flex items-center justify-center">
              <div className="text-center p-8">
                <div className="w-24 h-24 mx-auto mb-4 rounded-2xl bg-primary/20 flex items-center justify-center">
                  <span className="text-4xl font-bold text-primary">S</span>
                </div>
                <p className="text-muted-foreground">App Preview Image</p>
                <p className="text-sm text-muted-foreground mt-2">
                  (Add your app screenshots here)
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
