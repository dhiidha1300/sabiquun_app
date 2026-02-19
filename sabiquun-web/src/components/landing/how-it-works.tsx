import { Badge } from '@/components/ui/badge'
import { UserPlus, ListChecks, Target, TrendingUp } from 'lucide-react'

const steps = [
  {
    number: '01',
    icon: UserPlus,
    title: 'Sign Up & Join',
    description: 'Create your account and join our community of practicing Muslims committed to daily spiritual growth.',
    color: 'bg-blue-500/10 text-blue-600',
  },
  {
    number: '02',
    icon: ListChecks,
    title: 'Track Your Deeds',
    description: 'Log your 10 daily deeds including prayers and sunnah acts. Submit before the deadline each day.',
    color: 'bg-green-500/10 text-green-600',
  },
  {
    number: '03',
    icon: Target,
    title: 'Stay Accountable',
    description: 'Missed deeds incur small penalties that go to charity. This financial commitment helps you stay consistent.',
    color: 'bg-orange-500/10 text-orange-600',
  },
  {
    number: '04',
    icon: TrendingUp,
    title: 'Watch Your Growth',
    description: 'Track your progress over time, maintain streaks, earn achievements, and see your spiritual transformation.',
    color: 'bg-purple-500/10 text-purple-600',
  },
]

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-20 sm:py-32">
      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <Badge variant="secondary" className="mb-4">Simple Process</Badge>
          <h2 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            How Sabiquun Works
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Get started in minutes and begin your journey to consistent daily worship.
          </p>
        </div>

        <div className="mt-16 relative">
          {/* Connection line for desktop */}
          <div className="hidden lg:block absolute top-24 left-0 right-0 h-0.5 bg-border" />

          <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
            {steps.map((step, index) => (
              <div key={step.number} className="relative">
                {/* Step number badge */}
                <div className="flex flex-col items-center text-center">
                  <div className={`relative z-10 w-16 h-16 rounded-full ${step.color} flex items-center justify-center mb-6 ring-4 ring-background`}>
                    <step.icon className="h-7 w-7" />
                  </div>
                  <div className="text-sm font-medium text-muted-foreground mb-2">
                    Step {step.number}
                  </div>
                  <h3 className="text-xl font-semibold text-foreground mb-3">
                    {step.title}
                  </h3>
                  <p className="text-muted-foreground text-sm">
                    {step.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Additional info */}
        <div className="mt-16 p-8 rounded-2xl bg-primary/5 border border-primary/10">
          <div className="grid md:grid-cols-3 gap-8 text-center">
            <div>
              <div className="text-3xl font-bold text-primary">30 Days</div>
              <div className="text-sm text-muted-foreground mt-1">
                New member grace period with no penalties
              </div>
            </div>
            <div>
              <div className="text-3xl font-bold text-primary">12 Hours</div>
              <div className="text-sm text-muted-foreground mt-1">
                Grace period after midnight to submit reports
              </div>
            </div>
            <div>
              <div className="text-3xl font-bold text-primary">5,000 SOS</div>
              <div className="text-sm text-muted-foreground mt-1">
                Per missed deed goes to community charity
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
