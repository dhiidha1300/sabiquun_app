'use client'

import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import type { User, UserRole } from '@/lib/types/database'
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from '@/components/ui/sidebar'
import {
  LayoutDashboard,
  Users,
  CreditCard,
  FileText,
  AlertCircle,
  Receipt,
  BarChart3,
  Settings,
  ListChecks,
  Bell,
  FileSearch,
  Trophy,
  Calendar,
  BookOpen,
  LogOut,
  MessageSquare,
} from 'lucide-react'

interface SidebarProps {
  user: User
}

interface NavItem {
  title: string
  href: string
  icon: React.ComponentType<{ className?: string }>
  roles: UserRole[]
}

const mainNavItems: NavItem[] = [
  {
    title: 'Dashboard',
    href: '/dashboard',
    icon: LayoutDashboard,
    roles: ['admin', 'supervisor', 'cashier'],
  },
  {
    title: 'Analytics',
    href: '/dashboard/analytics',
    icon: BarChart3,
    roles: ['admin', 'supervisor', 'cashier'],
  },
]

const managementNavItems: NavItem[] = [
  {
    title: 'Users',
    href: '/dashboard/users',
    icon: Users,
    roles: ['admin'],
  },
  {
    title: 'Deed Templates',
    href: '/dashboard/deeds',
    icon: ListChecks,
    roles: ['admin'],
  },
  {
    title: 'Reports',
    href: '/dashboard/reports',
    icon: FileText,
    roles: ['admin', 'supervisor'],
  },
  {
    title: 'Leaderboard',
    href: '/dashboard/leaderboard',
    icon: Trophy,
    roles: ['admin', 'supervisor'],
  },
]

const financialNavItems: NavItem[] = [
  {
    title: 'Payments',
    href: '/dashboard/payments',
    icon: CreditCard,
    roles: ['admin', 'cashier'],
  },
  {
    title: 'Penalties',
    href: '/dashboard/penalties',
    icon: Receipt,
    roles: ['admin', 'cashier'],
  },
]

const requestsNavItems: NavItem[] = [
  {
    title: 'Excuses',
    href: '/dashboard/excuses',
    icon: AlertCircle,
    roles: ['admin', 'supervisor'],
  },
]

const systemNavItems: NavItem[] = [
  {
    title: 'Notifications',
    href: '/dashboard/notifications',
    icon: Bell,
    roles: ['admin'],
  },
  {
    title: 'WhatsApp',
    href: '/dashboard/whatsapp',
    icon: MessageSquare,
    roles: ['admin'],
  },
  {
    title: 'Content',
    href: '/dashboard/content',
    icon: BookOpen,
    roles: ['admin'],
  },
  {
    title: 'Rest Days',
    href: '/dashboard/rest-days',
    icon: Calendar,
    roles: ['admin'],
  },
  {
    title: 'Audit Logs',
    href: '/dashboard/audit-logs',
    icon: FileSearch,
    roles: ['admin'],
  },
  {
    title: 'Settings',
    href: '/dashboard/settings',
    icon: Settings,
    roles: ['admin'],
  },
]

export function DashboardSidebar({ user }: SidebarProps) {
  const pathname = usePathname()

  const filterByRole = (items: NavItem[]) => {
    return items.filter((item) => item.roles.includes(user.role))
  }

  const renderNavGroup = (
    label: string,
    items: NavItem[],
    showLabel: boolean = true
  ) => {
    const filteredItems = filterByRole(items)
    if (filteredItems.length === 0) return null

    return (
      <SidebarGroup>
        {showLabel && (
          <SidebarGroupLabel>{label}</SidebarGroupLabel>
        )}
        <SidebarGroupContent>
          <SidebarMenu>
            {filteredItems.map((item) => (
              <SidebarMenuItem key={item.href}>
                <SidebarMenuButton
                  asChild
                  isActive={pathname === item.href}
                >
                  <Link href={item.href}>
                    <item.icon className="h-4 w-4" />
                    <span>{item.title}</span>
                  </Link>
                </SidebarMenuButton>
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </SidebarGroupContent>
      </SidebarGroup>
    )
  }

  return (
    <Sidebar>
      <SidebarHeader>
        <Link href="/dashboard" className="flex items-center gap-2 px-4 py-2">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg overflow-hidden bg-white">
            <Image
              src="/assets/images/app-icon/logo.png"
              alt="Sabiquun Logo"
              width={40}
              height={40}
              className="object-contain"
              priority
            />
          </div>
          <div>
            <span className="text-lg font-bold">Sabiquun</span>
            <span className="text-xs text-muted-foreground block -mt-1">Admin Panel</span>
          </div>
        </Link>
      </SidebarHeader>

      <SidebarContent>
        {renderNavGroup('Main', mainNavItems, false)}
        {renderNavGroup('Management', managementNavItems)}
        {renderNavGroup('Financial', financialNavItems)}
        {renderNavGroup('Requests', requestsNavItems)}
        {renderNavGroup('System', systemNavItems)}
      </SidebarContent>

      <SidebarFooter>
        <div className="px-4 py-3 border-t">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary font-medium text-sm">
              {user.name?.charAt(0).toUpperCase() || 'U'}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate">{user.name || user.email}</p>
              <p className="text-xs text-muted-foreground capitalize">{user.role}</p>
            </div>
          </div>
        </div>
      </SidebarFooter>
    </Sidebar>
  )
}
