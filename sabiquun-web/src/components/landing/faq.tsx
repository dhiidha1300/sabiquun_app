'use client'

import { Badge } from '@/components/ui/badge'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'

const faqs = [
  {
    question: 'What happens if I miss submitting my daily report?',
    answer: 'If you don\'t submit your report by 12:00 PM the next day (12-hour grace period), you\'ll receive a penalty for a full 10 missed deeds. That\'s why it\'s important to submit your report even if you missed some prayers - partial completion is better than no submission at all.',
  },
  {
    question: 'How are penalties calculated?',
    answer: 'Penalties are calculated as: (10 - your completed deeds) × 5,000 Somali Shillings. For example, if you complete 8 out of 10 deeds, your penalty is 2 × 5,000 = 10,000 SOS. Some deeds like Sunnah Prayers are fractional, so partial completion counts.',
  },
  {
    question: 'Can I submit excuses for missed prayers?',
    answer: 'Yes! You can submit excuses for valid reasons like sickness, travel, or heavy rain (for outdoor work). Excuses are reviewed by supervisors and if approved, associated penalties are waived. You can even submit retroactive excuses for past dates.',
  },
  {
    question: 'What payment methods are accepted?',
    answer: 'We accept mobile money payments through ZAAD and eDahab. Simply submit your payment with the reference number through the app, and it will be reviewed and approved by our cashier team.',
  },
  {
    question: 'Is there a trial period for new members?',
    answer: 'Yes! New members get a 30-day grace period during which no penalties are incurred. This gives you time to build the habit and get comfortable with the system before financial accountability kicks in.',
  },
  {
    question: 'What happens if my penalty balance gets too high?',
    answer: 'If your penalty balance reaches 500,000 SOS, your account will be automatically deactivated. You\'ll receive warning notifications at 400,000 and 450,000 SOS. You can reactivate by clearing your balance with our cashier.',
  },
  {
    question: 'Can I track partial deeds?',
    answer: 'Yes! While prayers are binary (done or not done), some deeds like Sunnah Prayers can be tracked fractionally (0.1 to 1.0). This allows for partial credit when you do some but not all extra prayers.',
  },
  {
    question: 'Is my data private?',
    answer: 'Absolutely. Your deed submissions are private. Only you can see your detailed daily reports. Supervisors and admins can view aggregate statistics but your spiritual journey remains personal.',
  },
  {
    question: 'What happens to the penalty money?',
    answer: 'All penalty payments go towards community charitable initiatives. Your financial commitment not only keeps you accountable but also contributes to good causes in the community.',
  },
  {
    question: 'Can I use the app offline?',
    answer: 'Yes! You can save draft reports offline, and they will sync automatically when you reconnect to the internet. This ensures you can track your deeds even without internet access.',
  },
]

export function FAQ() {
  return (
    <section id="faq" className="py-20 sm:py-32">
      <div className="container px-4 md:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <Badge variant="secondary" className="mb-4">FAQ</Badge>
          <h2 className="text-3xl font-bold tracking-tight text-foreground sm:text-4xl">
            Frequently Asked Questions
          </h2>
          <p className="mt-4 text-lg text-muted-foreground">
            Got questions? We've got answers. If you can't find what you're looking for,
            feel free to contact us.
          </p>
        </div>

        <div className="mt-12 mx-auto max-w-3xl">
          <Accordion type="single" collapsible className="w-full">
            {faqs.map((faq, index) => (
              <AccordionItem key={index} value={`item-${index}`}>
                <AccordionTrigger className="text-left">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </div>
    </section>
  )
}
