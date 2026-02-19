'use client'

import Link from 'next/link'
import Image from 'next/image'
import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Menu, Moon, Sun, LayoutDashboard } from 'lucide-react'

interface UserProfile {
  name: string
  email: string
  photo_url: string | null
  role: string
}

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false)
  const [user, setUser] = useState<UserProfile | null>(null)

  useEffect(() => {
    // Check if user is authenticated
    const checkAuth = async () => {
      try {
        const response = await fetch('/api/auth/me', {
          credentials: 'include',
          cache: 'no-store',
        })
        if (response.ok) {
          const data = await response.json()
          if (data.profile) {
            setUser(data.profile)
          }
        }
      } catch (error) {
        // User not authenticated, ignore
      }
    }
    checkAuth()
  }, [])

  const navLinks = [
    { href: '/', label: 'Home' },
    { href: '#features', label: 'Features' },
    { href: '#how-it-works', label: 'How It Works' },
    { href: '#deeds', label: 'The Deeds' },
    { href: '#faq', label: 'FAQ' },
  ]

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between px-4 md:px-8">
        {/* Logo */}
        <Link href="/" className="flex items-center space-x-2">
          <Image
            src="/assets/images/app-icon/logo.png"
            alt="Sabiquun"
            width={32}
            height={32}
            className="h-8 w-8 rounded-lg"
          />
          <span className="text-xl font-bold text-foreground">Sabiquun</span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center space-x-6">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Desktop Actions */}
        <div className="hidden md:flex items-center space-x-4">
          {user ? (
            <Link href="/dashboard">
              <Button variant="ghost" size="sm" className="flex items-center gap-2">
                <Avatar className="h-6 w-6">
                  <AvatarImage src={user.photo_url || ''} alt={user.name} />
                  <AvatarFallback className="bg-primary/10 text-primary text-xs">
                    {user.name?.charAt(0).toUpperCase() || 'U'}
                  </AvatarFallback>
                </Avatar>
                <span>{user.name || user.email}</span>
              </Button>
            </Link>
          ) : (
            <Link href="/login">
              <Button variant="ghost" size="sm">
                Admin Login
              </Button>
            </Link>
          )}
          <Link href="#download">
            <Button size="sm">Download App</Button>
          </Link>
        </div>

        {/* Mobile Menu */}
        <Sheet open={isOpen} onOpenChange={setIsOpen}>
          <SheetTrigger asChild className="md:hidden">
            <Button variant="ghost" size="icon">
              <Menu className="h-5 w-5" />
              <span className="sr-only">Toggle menu</span>
            </Button>
          </SheetTrigger>
          <SheetContent side="right" className="w-[300px] sm:w-[400px]">
            <nav className="flex flex-col space-y-4 mt-8">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setIsOpen(false)}
                  className="text-lg font-medium text-foreground transition-colors hover:text-primary"
                >
                  {link.label}
                </Link>
              ))}
              <hr className="my-4" />
              {user ? (
                <Link href="/dashboard" onClick={() => setIsOpen(false)}>
                  <Button variant="outline" className="w-full flex items-center gap-2">
                    <LayoutDashboard className="h-4 w-4" />
                    Go to Dashboard
                  </Button>
                </Link>
              ) : (
                <Link href="/login" onClick={() => setIsOpen(false)}>
                  <Button variant="outline" className="w-full">
                    Admin Login
                  </Button>
                </Link>
              )}
              <Link href="#download" onClick={() => setIsOpen(false)}>
                <Button className="w-full">Download App</Button>
              </Link>
            </nav>
          </SheetContent>
        </Sheet>
      </div>
    </header>
  )
}
