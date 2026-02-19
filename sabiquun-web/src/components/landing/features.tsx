import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  CheckCircle2,
  Bell,
  CreditCard,
  Trophy,
  Users,
  Shield,
  Calendar,
  BarChart3
} from 'lucide-react'

const features = [
  {
    icon: CheckCircle2,
    title: 'Daily Deed Tracking',
    description: 'Track your 10 daily deeds including the 5 daily prayers and recommended sunnah acts with an intuitive interface.',
  },
  {
    icon: CreditCard,
    title: 'Financial Accountability',
    description: 'Stay committed with a penalty system that encourages consistency. Missed deeds result in small financial penalties that go to charity.',
  },
  {
    icon: Bell,
    title: 'Smart Reminders',
    description: 'Never miss a prayer or deed again. Get timely notifications via push, email, or WhatsApp to keep you on track.',
  },
  {
    icon: Trophy,
    title: 'Leaderboards & Achievements',
    description: 'Compete with your community, earn achievement badges, and climb the leaderboard as you maintain your daily practice.',
  },
  {
    icon: Users,
    title: 'Community Support',
    description: 'Join a supportive community of like-minded Muslims working together to improve their daily worship and accountability.',
  },
  {
    icon: Calendar,
    title: 'Excuse System',
    description: 'Life happens. Submit excuses for sickness, travel, or other valid reasons and get them approved without penalties.',
  },
  {
    icon: BarChart3,
    title: 'Progress Analytics',
    description: 'View detailed statistics about your spiritual journey. Track streaks, completion rates, and identify areas for improvement.',
  },
  {
    icon: Shield,
    title: 'Offline Support',
    description: 'No internet? No problem. Submit your deeds offline and they\'ll sync automatically when you\'re back online.',
  },
]

export function Features() {
  return (
    <section id="features" className="py-20 sm:py-32 bg-muted/30">
      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            Everything You Need to Stay Consistent
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Sabiquun provides all the tools you need to build lasting spiritual habits
            and stay accountable to your daily Islamic obligations.
          </p>
        </div>

        <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((feature) => (
            <Card key={feature.title} className="border-0 shadow-sm hover:shadow-md transition-shadow">
              <CardHeader>
                <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <feature.icon className="h-6 w-6 text-primary" />
                </div>
                <CardTitle className="text-lg">{feature.title}</CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription className="text-sm">
                  {feature.description}
                </CardDescription>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  )
}
