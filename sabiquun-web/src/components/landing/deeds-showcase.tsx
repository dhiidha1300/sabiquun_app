import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { Sun, Moon, BookOpen, Star, Sunrise, CloudSun } from 'lucide-react'

const faraid = [
  {
    name: 'Fajr Prayer',
    nameAr: 'صلاة الفجر',
    icon: Sunrise,
    description: 'Dawn prayer before sunrise',
    time: 'Before Sunrise',
  },
  {
    name: 'Dhuhr Prayer',
    nameAr: 'صلاة الظهر',
    icon: Sun,
    description: 'Noon prayer after zenith',
    time: 'Midday',
  },
  {
    name: 'Asr Prayer',
    nameAr: 'صلاة العصر',
    icon: CloudSun,
    description: 'Afternoon prayer',
    time: 'Afternoon',
  },
  {
    name: 'Maghrib Prayer',
    nameAr: 'صلاة المغرب',
    icon: Sun,
    description: 'Sunset prayer',
    time: 'Sunset',
  },
  {
    name: 'Isha Prayer',
    nameAr: 'صلاة العشاء',
    icon: Moon,
    description: 'Night prayer',
    time: 'Night',
  },
]

const sunnah = [
  {
    name: 'Duha Prayer',
    nameAr: 'صلاة الضحى',
    icon: Sun,
    description: 'Mid-morning voluntary prayer',
  },
  {
    name: 'Quran Recitation',
    nameAr: 'قراءة القرآن',
    icon: BookOpen,
    description: 'Read at least one Juz daily',
  },
  {
    name: 'Sunnah Prayers',
    nameAr: 'السنن الرواتب',
    icon: Star,
    description: 'Voluntary prayers with obligatory ones',
  },
  {
    name: 'Athkar',
    nameAr: 'الأذكار',
    icon: Star,
    description: 'Morning and evening remembrances',
  },
  {
    name: 'Witr Prayer',
    nameAr: 'صلاة الوتر',
    icon: Moon,
    description: 'Odd-numbered night prayer',
  },
]

export function DeedsShowcase() {
  return (
    <section id="deeds" className="py-20 sm:py-32 bg-muted/30">
      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <Badge variant="secondary" className="mb-4">The 10 Daily Deeds</Badge>
          <h2 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            What You'll Track Every Day
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            5 obligatory prayers (Fara'id) and 5 recommended acts (Sunnah) to build
            a complete daily spiritual routine.
          </p>
        </div>

        <div className="mt-16 grid lg:grid-cols-2 gap-8">
          {/* Fara'id Section */}
          <div>
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center">
                <Star className="h-5 w-5 text-primary-foreground" />
              </div>
              <div>
                <h3 className="text-xl font-semibold">Fara'id (Obligatory)</h3>
                <p className="text-sm text-muted-foreground">The 5 daily prayers</p>
              </div>
            </div>
            <div className="space-y-3">
              {faraid.map((deed) => (
                <Card key={deed.name} className="border-0 shadow-sm">
                  <CardContent className="p-4">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                        <deed.icon className="h-6 w-6 text-primary" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <h4 className="font-medium text-foreground">{deed.name}</h4>
                          <span className="text-sm text-muted-foreground">({deed.nameAr})</span>
                        </div>
                        <p className="text-sm text-muted-foreground">{deed.description}</p>
                      </div>
                      <Badge variant="outline" className="flex-shrink-0">
                        {deed.time}
                      </Badge>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Sunnah Section */}
          <div>
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 rounded-full bg-green-600 flex items-center justify-center">
                <Star className="h-5 w-5 text-white" />
              </div>
              <div>
                <h3 className="text-xl font-semibold">Sunnah (Recommended)</h3>
                <p className="text-sm text-muted-foreground">Additional good deeds</p>
              </div>
            </div>
            <div className="space-y-3">
              {sunnah.map((deed) => (
                <Card key={deed.name} className="border-0 shadow-sm">
                  <CardContent className="p-4">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-lg bg-green-500/10 flex items-center justify-center flex-shrink-0">
                        <deed.icon className="h-6 w-6 text-green-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <h4 className="font-medium text-foreground">{deed.name}</h4>
                          <span className="text-sm text-muted-foreground">({deed.nameAr})</span>
                        </div>
                        <p className="text-sm text-muted-foreground">{deed.description}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>

        {/* Calculation note */}
        <div className="mt-12 text-center">
          <p className="text-sm text-muted-foreground max-w-2xl mx-auto">
            <strong>Penalty Calculation:</strong> For each missed deed out of 10,
            a penalty of 5,000 Somali Shillings is incurred. For example, if you complete
            7 out of 10 deeds, you'll have a penalty of 15,000 SOS (3 missed × 5,000).
          </p>
        </div>
      </div>
    </section>
  )
}
