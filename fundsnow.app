import { DashboardContent } from "./components/DashboardContent"
import { NotificationProvider } from "./context/NotificationContext"
import { DashboardProvider } from "./context/DashboardContext"
import { Toaster } from "@/components/ui/toaster"

export default function DashboardPage() {
  return (
    <NotificationProvider>
      <DashboardProvider>
        <DashboardContent />
        <Toaster />
      </DashboardProvider>
    </NotificationProvider>
  )
}

import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Snow Wallet Dashboard",
  description: "Manage your Snow Coins and mining operations",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}

export type NotificationType = 'purchase' | 'live' | 'earnings' | 'rewards' | 'transaction';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  timestamp: number;
  read: boolean;
  data?: any;
}

import { DashboardContent } from "../components/DashboardContent"
import { DashboardProvider } from "../context/DashboardContext"

export default function DashboardPage() {
  return (
    <DashboardProvider>
      <DashboardContent />
    </DashboardProvider>
  )
}

"use client"

import React, { createContext, useContext, useState } from 'react'
import { Notification, NotificationType } from '../types/notifications'
import { toast } from "@/components/ui/use-toast"

interface NotificationContextType {
  notifications: Notification[];
  unreadCount: number;
  addNotification: (type: NotificationType, title: string, message: string, data?: any) => void;
  markAsRead: (id: string) => void;
  markAllAsRead: () => void;
  clearNotifications: () => void;
}

const NotificationContext = createContext<NotificationContextType | undefined>(undefined)

export const useNotifications = () => {
  const context = useContext(NotificationContext)
  if (!context) {
    throw new Error('useNotifications must be used within a NotificationProvider')
  }
  return context
}

export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [notifications, setNotifications] = useState<Notification[]>([])

  const addNotification = (type: NotificationType, title: string, message: string, data?: any) => {
    const newNotification: Notification = {
      id: Date.now().toString(),
      type,
      title,
      message,
      timestamp: Date.now(),
      read: false,
      data
    }
    setNotifications(prev => [newNotification, ...prev])
    
    // Show toast for new notifications
    toast({
      title: title,
      description: message,
    })
  }

  const markAsRead = (id: string) => {
    setNotifications(prev =>
      prev.map(notification =>
        notification.id === id ? { ...notification, read: true } : notification
      )
    )
  }

  const markAllAsRead = () => {
    setNotifications(prev =>
      prev.map(notification => ({ ...notification, read: true }))
    )
  }

  const clearNotifications = () => {
    setNotifications([])
  }

  const unreadCount = notifications.filter(n => !n.read).length

  return (
    <NotificationContext.Provider value={{
      notifications,
      unreadCount,
      addNotification,
      markAsRead,
      markAllAsRead,
      clearNotifications
    }}>
      {children}
    </NotificationContext.Provider>
  )
}

"use client"

import React, { createContext, useContext, useState } from 'react'

interface DashboardContextType {
  miningActive: boolean
  snowCoins: number
  satoshis: number
  streamViews: number
  lastStreamCoins: number
  setMiningActive: (active: boolean) => void
  setSnowCoins: (coins: number) => void
  setSatoshis: (sats: number) => void
  setStreamViews: (views: number) => void
  setLastStreamCoins: (coins: number) => void
}

const DashboardContext = createContext<DashboardContextType | undefined>(undefined)

export const useDashboard = () => {
  const context = useContext(DashboardContext)
  if (!context) {
    throw new Error('useDashboard must be used within a DashboardProvider')
  }
  return context
}

export const DashboardProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [miningActive, setMiningActive] = useState(false)
  const [snowCoins, setSnowCoins] = useState(0)
  const [satoshis, setSatoshis] = useState(0)
  const [streamViews, setStreamViews] = useState(0)
  const [lastStreamCoins, setLastStreamCoins] = useState(0)

  return (
    <DashboardContext.Provider value={{
      miningActive,
      snowCoins,
      satoshis,
      streamViews,
      lastStreamCoins,
      setMiningActive,
      setSnowCoins,
      setSatoshis,
      setStreamViews,
      setLastStreamCoins
    }}>
      {children}
    </DashboardContext.Provider>
  )
}

"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { useDashboard } from "../context/DashboardContext"
import Image from "next/image"
import { motion } from "framer-motion"
import { GiftIcon, Timer, Volume2Icon as Volume2Off, Cog } from 'lucide-react'
import { SettingsModal } from '@/components/SettingsModal'

const TOKEN_PACKS = [
  { tokens: 2_000_000, price: 1.99 },
  { tokens: 10_000_000, price: 9.99 },
  { tokens: 50_000_000, price: 49.99 },
  { tokens: 110_000_000, price: 99.99, bestValue: true },
]

const POWER_UPS = [
  { name: "2 Day Sessions", tokens: 1_000_000, icon: Timer, count: 1 },
  { name: "3 Day Sessions", tokens: 1_500_000, icon: Timer, count: 2 },
  { name: "7 Day Sessions", tokens: 3_000_000, icon: Timer, count: 3, bestValue: true },
  { name: "No Ads (7 Days)", tokens: 5_000_000, icon: Volume2Off },
]

export function Wallet() {
  const { snowCoins, setSnowCoins } = useDashboard()
  const [purchasedItems, setPurchasedItems] = useState<{name: string, icon: any}[]>([])
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  const handlePurchase = (tokens: number, price: number) => {
    console.log(`Processing payment of $${price} for ${tokens} Snow Tokens`)
    setSnowCoins(prev => prev + tokens)
    setPurchasedItems(prev => [...prev, {
      name: `${(tokens / 1_000_000).toFixed(0)}M Snow Tokens`,
      icon: GiftIcon
    }])
  }

  const handlePowerUpPurchase = (name: string, tokenCost: number, icon: any) => {
    if (snowCoins >= tokenCost) {
      setSnowCoins(prev => prev - tokenCost)
      setPurchasedItems(prev => [...prev, { name, icon }])
      console.log(`Purchased ${name} for ${tokenCost} tokens`)
    }
  }

  const CardWrapper = ({ children, bestValue = false }: { children: React.ReactNode, bestValue?: boolean }) => (
    <Card className={`relative h-[300px] overflow-hidden ${bestValue ? 'col-span-1' : ''}`}>
      {bestValue && (
        <div className="absolute top-0 left-0 right-0 bg-green-500 text-white text-center py-1 font-semibold">
          Best Value
        </div>
      )}
      <CardContent className={`p-6 flex flex-col items-center justify-between h-full ${bestValue ? 'pt-10' : ''}`}>
        {children}
      </CardContent>
    </Card>
  )

  return (
    <div className="space-y-12 p-4">
      <section>
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <h1 className="text-4xl font-bold">Buy Token Packs</h1>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setIsSettingsOpen(true)}
              className="flex items-center gap-2"
            >
              <Cog className="w-4 h-4" />
              Settings
            </Button>
          </div>
        </div>
        <p className="text-xl text-gray-500 mb-8">
          Use the <span className="font-semibold text-emerald-400">Snow token</span> to buy power-ups. You may receive free surprise airdrops! <GiftIcon className="inline-block w-6 h-6 text-red-500" />
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {TOKEN_PACKS.map((pack, index) => (
            <CardWrapper key={index} bestValue={pack.bestValue}>
              <div className="relative w-24 h-24 mb-4">
                <div className="w-full h-full rounded-full bg-gradient-to-b from-emerald-400 to-emerald-600 flex items-center justify-center">
                  <Image
                    src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/IMG_3893.JPG-wBHmryaUs214AmyU96kKypkKdpXpCP.jpeg"
                    alt="Snow Token"
                    width={96}
                    height={96}
                    className="object-contain p-2"
                  />
                </div>
              </div>
              <h2 className="text-2xl font-bold mb-2">{(pack.tokens / 1_000_000).toFixed(0)} Million</h2>
              <p className="text-3xl font-bold text-green-500">${pack.price.toFixed(2)}</p>
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="mt-4 px-6 py-2 bg-green-500 text-white rounded-full font-semibold hover:bg-green-600 transition-colors"
                onClick={() => handlePurchase(pack.tokens, pack.price)}
              >
                Buy Now
              </motion.button>
            </CardWrapper>
          ))}
        </div>
      </section>

      <section>
        <h2 className="text-4xl font-bold mb-2">Power-Ups & Items</h2>
        <p className="text-xl text-gray-500 mb-8">
          Extend the length of your next mining session with longer sessions!
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {POWER_UPS.map((powerUp, index) => (
            <CardWrapper key={index} bestValue={powerUp.bestValue}>
              <div className="flex gap-2 mb-4 justify-center items-center h-24">
                {powerUp.count ? (
                  [...Array(powerUp.count)].map((_, i) => (
                    <powerUp.icon key={i} className="w-16 h-16 text-gray-600" />
                  ))
                ) : (
                  <powerUp.icon className="w-16 h-16 text-gray-600" />
                )}
              </div>
              <h2 className="text-2xl font-bold mb-2">{powerUp.name}</h2>
              <div className="flex items-center gap-2">
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/IMG_3893.JPG-wBHmryaUs214AmyU96kKypkKdpXpCP.jpeg"
                  alt="Snow Token"
                  width={24}
                  height={24}
                  className="object-contain"
                />
                <p className="text-2xl font-bold text-green-500">
                  {powerUp.tokens.toLocaleString()}
                </p>
              </div>
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="mt-4 px-6 py-2 bg-green-500 text-white rounded-full font-semibold hover:bg-green-600 transition-colors"
                onClick={() => handlePowerUpPurchase(powerUp.name, powerUp.tokens, powerUp.icon)}
              >
                Purchase
              </motion.button>
            </CardWrapper>
          ))}
        </div>
      </section>

      <section>
        <h2 className="text-4xl font-bold mb-2">My Items</h2>
        <p className="text-xl text-gray-500 mb-8">
          Items are applied automatically in the order they were purchased
        </p>
        <div className="bg-gray-800/50 rounded-lg p-4">
          {purchasedItems.length === 0 ? (
            <p className="text-gray-400 text-center">No items purchased yet</p>
          ) : (
            <ul className="space-y-2">
              {purchasedItems.map((item, index) => (
                <li key={index} className="flex items-center gap-2 text-gray-300">
                  <item.icon className="w-4 h-4" />
                  {item.name}
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
      <SettingsModal isOpen={isSettingsOpen} onClose={() => setIsSettingsOpen(false)} />
    </div>
  )
}

"use client"

import { useState, useEffect, useRef } from "react"
import { ArrowUp, Users, Coins, Menu, ArrowRightLeft, Share2, Download } from 'lucide-react'
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { cn } from "@/lib/utils"
import Image from "next/image"
import { motion, AnimatePresence } from "framer-motion"
import { useDashboard } from "../context/DashboardContext"
import { LiveStreamersMenu } from "@/components/LiveStreamersMenu"
import { SnowTokens } from "@/components/SnowTokens"
import { FriendsListModal } from "@/components/FriendsListModal"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Wallet } from "./Wallet"
import { toast } from "@/components/ui/use-toast"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { NotificationBell } from "@/components/NotificationBell"
import { useNotifications } from '@/app/context/NotificationContext'

interface Friend {
  id: number
  name: string
  avatar: string
}

export function DashboardContent() {
  const {
    miningActive,
    snowCoins,
    satoshis,
    streamViews,
    lastStreamCoins,
    setMiningActive,
    setSnowCoins,
    setSatoshis,
    setStreamViews,
    setLastStreamCoins
  } = useDashboard()
  const { addNotification } = useNotifications()

  const [countdownEndTime, setCountdownEndTime] = useState<number | null>(null)
  const [buttonDisabled, setButtonDisabled] = useState(false)
  const [miningProgress, setMiningProgress] = useState(0)
  const [isCooldown, setIsCooldown] = useState(false)
  const [isMiningStarted, setIsMiningStarted] = useState(false)
  const [satoshiRate, setSatoshiRate] = useState(0.00000036) // 36 satoshis per hour
  const [snowTokenRate, setSnowTokenRate] = useState(0.0000252) // 0.0252 Snow Tokens per hour
  const [friendCount, setFriendCount] = useState(0)
  const [friends, setFriends] = useState<Friend[]>([])
  const [isFriendsModalOpen, setIsFriendsModalOpen] = useState(false)
  const [referralInput, setReferralInput] = useState('')
  const [isInsufficientFundsModalOpen, setIsInsufficientFundsModalOpen] = useState(false)
  const [isWalletOpen, setIsWalletOpen] = useState(false)
  const [isWithdrawSwapModalOpen, setIsWithdrawSwapModalOpen] = useState(false)
  const [isStreaming, setIsStreaming] = useState(false)
  const [streamEnded, setStreamEnded] = useState(false)
  const [shareModalOpen, setShareModalOpen] = useState(false)
  const [streamDuration, setStreamDuration] = useState(0)
  const [streamInterval, setStreamInterval] = useState<NodeJS.Timeout | null>(null)
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isSendTokensModalOpen, setIsSendTokensModalOpen] = useState(false); // Added state for Send Tokens modal
  const videoRef = useRef<HTMLVideoElement>(null);

  const TOTAL_MINING_TIME = 24 * 60 * 60 // 24 hours in seconds
  const STREAM_PRICE = 50 // Price to watch a stream in Snow Tokens
  const SATOSHI_TO_SNOW_RATE = 70 // 1 Snow Token = 70 Satoshis

  useEffect(() => {
    // Initialize Satoshis to 2 million and Snow Tokens to 10 million
    // Removed balance initialization
  }, [])

  useEffect(() => {
    let timer: NodeJS.Timeout
    if (miningActive) {
      timer = setInterval(() => {
        const now = Date.now()
        const timeLeft = countdownEndTime ? Math.max(0, countdownEndTime - now) : 0
        if (timeLeft <= 0) {
          clearInterval(timer)
          setMiningActive(false)
          setButtonDisabled(false)
          setIsCooldown(false)
          setMiningProgress(1)
          setCountdownEndTime(null)
          setIsMiningStarted(false)
          // Reset rates when mining stops
          setSatoshiRate(0.00000036)
          setSnowTokenRate(0.0000252)
          addNotification('rewards', 'Mining Reward', `You earned ${(snowTokenRate * 3600).toFixed(8)} Snow Tokens from mining!`)
        } else {
          const progress = countdownEndTime ? 1 - timeLeft / TOTAL_MINING_TIME : 0
          setMiningProgress(progress)
          setIsCooldown(progress >= 0.5)
          
          // Update mined amounts with precise calculations
          setSatoshis(prev => {
            const newValue = prev + satoshiRate
            return Math.round(newValue * 1e8) / 1e8 // Round to 8 decimal places
          })
          setSnowCoins(prev => {
            const newValue = prev + snowTokenRate
            return Math.round(newValue * 1e8) / 1e8 // Round to 8 decimal places
          })
          
        }
      }, 1000)
    }
    return () => clearInterval(timer)
  }, [miningActive, countdownEndTime, friendCount, setMiningActive, setSatoshis, setSnowCoins, satoshiRate, snowTokenRate])

  const formatCountdown = (totalSeconds: number) => {
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = Math.floor(totalSeconds % 60)
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  const handleMiningToggle = () => {
    if (!miningActive && !buttonDisabled) {
      const endTime = Date.now() + TOTAL_MINING_TIME * 1000
      setCountdownEndTime(endTime)
      setMiningActive(true)
      setButtonDisabled(true)
      setMiningProgress(0)
      setIsCooldown(false)
      setIsMiningStarted(true)
      // Update rates when mining starts
      const friendBonus = friendCount * 0.00000012 // 12 satoshis per friend per hour
      setSatoshiRate(0.00000036 + friendBonus)
      setSnowTokenRate(0.0000252 + (friendBonus * 70)) // Assuming 1 Snow Token = 70 Satoshis
    } else if (miningActive) {
      setMiningActive(false)
      setCountdownEndTime(null)
      setMiningProgress(0)
      setIsCooldown(false)
      setButtonDisabled(false)
      setIsMiningStarted(false)
      // Reset rates when mining stops
      setSatoshiRate(0.00000036)
      setSnowTokenRate(0.0000252)
    }
  }

  const addFriend = () => {
    const newFriend: Friend = {
      id: friends.length + 1,
      name: `Friend ${friends.length + 1}`,
      avatar: `/placeholder.svg?height=40&width=40`
    }
    setFriends([...friends, newFriend])
    setFriendCount(prev => prev + 1)
  }

  const addFriendWithReferral = () => {
    if (referralInput.trim() !== '') {
      const newFriend: Friend = {
        id: friends.length + 1,
        name: `Friend ${friends.length + 1}`,
        avatar: `/placeholder.svg?height=40&width=40`
      }
      setFriends([...friends, newFriend])
      setFriendCount(prev => prev + 1)
      setReferralInput('')
    }
  }

  const openFriendsModal = () => {
    setIsFriendsModalOpen(true)
  }

  const setupCamera = async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({ 
        video: {
          width: { ideal: 1920 },
          height: { ideal: 1080 },
          facingMode: "user"
        },
        audio: true 
      });
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
      }
      return true;
    } catch (error) {
      console.error('Error accessing camera:', error);
      toast({
        title: "Camera Access Error",
        description: "Unable to access your camera. Please check permissions.",
        variant: "destructive"
      });
      return false;
    }
  };

  const handleStreamPayment = async () => {
    if (snowCoins >= STREAM_PRICE) {
      const cameraReady = await setupCamera();
      if (!cameraReady) return;

      setSnowCoins(prev => prev - STREAM_PRICE);
      setIsStreaming(true);
      setStreamEnded(false);
      setStreamDuration(0);
      setStreamViews(0);
      setLastStreamCoins(0);
      addNotification('live', 'Stream Started', 'Your stream has begun. Earn Snow Tokens and gain viewers!')
      const interval = setInterval(() => {
        setStreamDuration(prev => prev + 1);
        setStreamViews(prev => prev + Math.floor(Math.random() * 5));
        setLastStreamCoins(prev => prev + (Math.random() * 0.1));
      }, 1000);
      
      setStreamInterval(interval);
      
    } else {
      setIsInsufficientFundsModalOpen(true);
    }
  };

  const handleEndStream = () => {
    setIsStreaming(false);
    setStreamEnded(true);
    if (streamInterval) {
      clearInterval(streamInterval);
    }
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    addNotification('earnings', 'Stream Ended', `You earned ${lastStreamCoins.toFixed(2)} Snow Tokens from your stream!`)
    toast({
      title: "Stream Ended",
      description: `You streamed for ${formatCountdown(streamDuration)}. Great job!`,
    });
  };

  const handleShare = () => {
    // Simulated share functionality with watermark
    toast({
      title: "Stream Shared",
      description: "Your stream has been shared to your network with the logo watermark!",
    });
  };

  const handleDownload = () => {
    // Simulated download functionality with watermark
    toast({
      title: "Stream Downloaded",
      description: "Your stream recording has been saved to your device with the logo watermark.",
    });
  };

  useEffect(() => {
    return () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
    };
  }, [stream]);

  const getStreamThumbnail = () => {
    if (!videoRef.current) return null;
    
    const canvas = document.createElement('canvas');
    canvas.width = videoRef.current.videoWidth;
    canvas.height = videoRef.current.videoHeight;
    const ctx = canvas.getContext('2d');
    ctx?.drawImage(videoRef.current, 0, 0);
    return canvas.toDataURL('image/jpeg');
  };

  const currentUserStream = {
    active: isStreaming,
    thumbnailUrl: isStreaming ? (getStreamThumbnail() || "/placeholder.svg?height=100&width=180") : "",
    viewers: streamViews
  };


  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 to-[#0A1A2F] text-white p-4 sm:p-6">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <header className="flex items-center justify-between mb-12">
          <motion.button 
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="h-10 px-4 flex items-center justify-center text-sm font-medium bg-gradient-to-r from-blue-600 to-blue-400 bg-clip-text text-transparent hover:from-blue-700 hover:to-blue-500 transition-colors rounded-full border border-blue-400/20"
            aria-label="Toggle Wallet"
            onClick={() => setIsWalletOpen(!isWalletOpen)}
          >
            {isWalletOpen ? 'Dashboard' : 'Wallet'}
          </motion.button>
          <div className="flex gap-4">
            <NotificationBell />
            <LiveStreamersMenu className="h-10 w-10" currentUserStream={currentUserStream} />
          </div>
        </header>

        {/* Currency Indicators */}
        <div className="flex justify-between mb-4">
          <div className="flex items-center gap-2">
            <div className="w-12 h-12 rounded-full bg-gradient-to-r from-[#F9D923] to-[#EB5757] flex items-center justify-center shadow-lg shadow-[#F9D923]/20">
              <span className="text-lg font-bold">₿</span>
            </div>
            <span className="text-xl font-mono">{satoshis.toFixed(8).padStart(10, '0')}</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-12 h-12 rounded-full bg-gradient-to-r from-emerald-400 to-cyan-400 flex items-center justify-center shadow-lg shadow-emerald-400/20">
              <div className="relative w-8 h-8">
                <Image
                  src="https://hebbkx1anhila5yf.public.blob.vercel-storage.com/IMG_3893-removebg-preview-apm1UNOncdodiFRfqnXcRqnlpBSoLh.png"
                  alt="Snow Token Logo"
                  fill
                  className="object-contain brightness-0 invert"
                  priority
                />
              </div>
            </div>
            <span className="text-xl font-mono">{snowCoins.toFixed(8).padStart(10, '0')}</span>
          </div>
        </div>

        {isWalletOpen ? (
          <Wallet />
        ) : (
          <>
            {/* Mining Animation */}
            <div className="relative h-48 mb-8 bg-gradient-to-b from-slate-800/50 to-slate-900/50 rounded-xl backdrop-blur-xl p-4 overflow-hidden">
              <SnowTokens progress={miningProgress} isMiningStarted={isMiningStarted} />
              <div className="absolute bottom-2 left-0 right-0 text-center text-sm font-semibold z-10">
                {countdownEndTime !== null ? (
                  <>
                    {isCooldown ? "Cooldown: " : "Mining: "}
                    {formatCountdown(Math.max(0, countdownEndTime - Date.now()) / 1000)}
                  </>
                ) : (
                  "Ready to mine"
                )}
              </div>
            </div>

            {/* Controls */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
              <Button
                variant={miningActive ? "destructive" : "default"}
                className="h-14 rounded-xl font-semibold"
                onClick={handleMiningToggle}
                disabled={buttonDisabled}
              >
                {miningActive ? "Stop Mining" : countdownEndTime !== null ? "Mining Cooldown" : "Start Mining"}
              </Button>
              <Button
                variant="default"
                className="h-14 rounded-xl font-semibold bg-gradient-to-r from-blue-600 to-blue-400 hover:from-blue-700 hover:to-blue-500 text-white shadow-lg shadow-blue-500/30"
                onClick={isStreaming ? handleEndStream : handleStreamPayment}
              >
                {isStreaming ? "End Streaming" : "Start Streaming"}
              </Button>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-2 gap-4 mb-8">
              {/* Mining Stats */}
              <div className="space-y-2 bg-slate-800/50 p-4 rounded-xl backdrop-blur-sm">
                <h2 className="text-base font-semibold">Mining Stats</h2>
                <div>
                  <div className="flex justify-between text-xs text-gray-400 mb-1">
                    <span>Satoshi Rate</span>
                    <span>{(satoshiRate * 3600).toFixed(8).padStart(10, '0')} /hr</span>
                  </div>
                  <Progress value={miningProgress * 100} className="h-1.5 bg-slate-700" indicatorClassName="bg-[#4DD0E1]" />
                </div>
                <div>
                  <div className="flex justify-between text-xs text-gray-400 mb-1">
                    <span>Snow Token Rate</span>
                    <span>{(snowTokenRate * 3600).toFixed(8).padStart(10, '0')} /hr</span>
                  </div>
                  <Progress value={miningProgress * 100} className="h-1.5 bg-slate-700" indicatorClassName="bg-[#FF7F7F]" />
                </div>
                <div className="flex justify-between text-xs text-gray-400">
                  <span>Friends Bonus</span>
                  <span>+{(friendCount * 0.000000012 * 3600).toFixed(8).padStart(10, '0')} /hr</span>
                </div>
              </div>

              {/* Streaming Stats */}
              <div className="space-y-2 bg-slate-800/50 p-4 rounded-xl backdrop-blur-sm">
                <h2 className="text-base font-semibold">
                  {isStreaming ? "Current Stream Stats" : "Last Stream Stats"}
                </h2>
                {isStreaming && (
                  <div className="grid grid-cols-1 gap-4 mb-4">
                    {/* Stream Preview */}
                    <div className="relative aspect-video bg-black rounded-lg overflow-hidden">
                      <video
                        ref={videoRef}
                        autoPlay
                        playsInline
                        muted
                        className="absolute inset-0 w-full h-full object-cover transform scale-x-[-1]"
                        onError={(e) => {
                          console.error('Video error:', e);
                          toast({
                            title: "Video Error",
                            description: "There was an error with the video preview.",
                            variant: "destructive"
                          });
                        }}
                      />
                      {/* Stream Overlay */}
                      <div className="absolute top-0 left-0 right-0 p-2 bg-gradient-to-b from-black/50 to-transparent">
                        <div className="flex items-center gap-2">
                          <div className="flex items-center gap-1 bg-red-500 px-2 py-0.5 rounded-full text-xs font-medium">
                            <span className="w-2 h-2 rounded-full bg-white animate-pulse" />
                            LIVE
                          </div>
                          <div className="flex items-center gap-1 bg-black/50 px-2 py-0.5 rounded-full text-xs">
                            <Users className="w-3 h-3" />
                            {streamViews}
                          </div>
                        </div>
                      </div>
                      {/* Stream Duration */}
                      <div className="absolute bottom-0 right-0 p-2 bg-black/50 text-xs font-medium rounded-tl-lg">
                        {formatCountdown(streamDuration)}
                      </div>
                    </div>
                    
                    {/* Stream Info */}
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-black/20 p-3 rounded-lg">
                        <div className="flex items-center gap-1 text-xs text-gray-400 mb-1">
                          <Users className="w-4 h-4 text-[#3ABAB4]" />
                          Viewers
                        </div>
                        <span className="text-lg font-semibold">{streamViews}</span>
                      </div>
                      <div className="bg-black/20 p-3 rounded-lg">
                        <div className="flex items-center gap-1 text-xs text-gray-400 mb-1">
                          <Coins className="w-4 h-4 text-[#F9D923]" />
                          Earned
                        </div>
                        <span className="text-lg font-semibold">{lastStreamCoins.toFixed(2)}</span>
                      </div>
                    </div>
                  </div>
                )}
                {!isStreaming && (
                  <>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-1">
                        <Users className="w-4 h-4 text-[#3ABAB4]" />
                        <span className="text-xs text-gray-400">Last Stream Viewers</span>
                      </div>
                      <span className="text-sm font-semibold">{streamViews}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-1">
                        <Coins className="w-4 h-4 text-[#F9D923]" />
                        <span className="text-xs text-gray-400">Last Stream Earnings</span>
                      </div>
                      <span className="text-sm font-semibold">{lastStreamCoins.toFixed(2)}</span>
                    </div>
                  </>
                )}
              </div>
            </div>

            {/* Quick Actions */}
            <div className="grid grid-cols-3 gap-2">
              <QuickActionButton 
                icon={streamEnded && !isStreaming ? <Share2 className="w-6 h-6 text-pink-400 group-hover:scale-110 transition-transform" /> :
                      isStreaming ? <Share2 className="w-6 h-6 text-pink-400 group-hover:scale-110 transition-transform" /> :
                      <ArrowUp className="w-6 h-6 text-pink-400 group-hover:scale-110 transition-transform" />} 
                label={streamEnded && !isStreaming ? "Share Stream" : isStreaming ? "Share Stream" : "Send"} 
                gradient="from-pink-400/20 to-purple-400/20" 
                onClick={() => {
                  if (isStreaming || streamEnded) {
                    setShareModalOpen(true);
                  } else {
                    setIsSendTokensModalOpen(true); // Updated onClick handler
                  }
                }}
              />
              <QuickActionButton 
                icon={<span className="text-white font-bold text-xl">₿</span>} 
                label="Withdraw/Swap" 
                gradient="from-orange-500/20 to-red-500/20" 
                onClick={() => setIsWithdrawSwapModalOpen(true)}
              />
              <QuickActionButton 
                icon={<Users className="w-6 h-6 text-blue-400 group-hover:scale-110 transition-transform" />} 
                label="Add Friend" 
                gradient="from-blue-400/20 to-cyan-400/20" 
                onClick={openFriendsModal}
              />
            </div>
          </>
        )}
      </div>
      <FriendsListModal 
        isOpen={isFriendsModalOpen} 
        onClose={() => setIsFriendsModalOpen(false)} 
        friends={friends}
        referralInput={referralInput}
        setReferralInput={setReferralInput}
        addFriendWithReferral={addFriendWithReferral}
      />
      <Dialog open={isInsufficientFundsModalOpen} onOpenChange={setIsInsufficientFundsModalOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Insufficient Funds</DialogTitle>
          </DialogHeader>
          <p>You need 50 Snow Tokens to start streaming. Please buy more tokens in the Wallet tab if you don't have enough.</p>
          <DialogFooter>
            <Button onClick={() => setIsInsufficientFundsModalOpen(false)}>Close</Button>
            <Button variant="default" onClick={() => {
              setIsInsufficientFundsModalOpen(false)
              setIsWalletOpen(true)
            }}>
              Go to Wallet
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      <WithdrawSwapModal 
        isOpen={isWithdrawSwapModalOpen}
        onClose={() => setIsWithdrawSwapModalOpen(false)}
        satoshis={satoshis}
        setSatoshis={setSatoshis}
        setSnowCoins={setSnowCoins}
      />
      <ShareModal 
        isOpen={shareModalOpen} 
        onClose={() => setShareModalOpen(false)} 
        onShare={handleShare}
        onDownload={handleDownload}
      />
      <SendTokensModal isOpen={isSendTokensModalOpen} onClose={() => setIsSendTokensModalOpen(false)} /> {/* Added SendTokensModal */}
    </div>
  )
}

interface QuickActionButtonProps {
  icon: React.ReactNode
  label: string
  gradient: string
  onClick?: () => void
}

const QuickActionButton: React.FC<QuickActionButtonProps> = ({ icon, label, gradient, onClick }) => (
  <motion.button 
    whileHover={{ scale: 1.05 }}
    whileTap={{ scale: 0.95 }}
    className={`aspect-square rounded-full bg-gradient-to-br ${gradient} p-0.5 group`}
    aria-label={label}
    onClick={onClick}
  >
    <div className="h-full w-full rounded-full bg-slate-900/90 flex items-center justify-center">
      <div className="text-inherit">
        {icon}
      </div>
    </div>
  </motion.button>
)

interface WithdrawSwapModalProps {
  isOpen: boolean
  onClose: () => void
  satoshis: number
  setSatoshis: (value: number) => void
  setSnowCoins: (value: number) => void
}

const WithdrawSwapModal: React.FC<WithdrawSwapModalProps> = ({ isOpen, onClose, satoshis, setSatoshis, setSnowCoins }) => {
  const [withdrawAmount, setWithdrawAmount] = useState(0)
  const SATOSHI_TO_SNOW_RATE = 70 // 1 Snow Token = 70 Satoshis

  const handleWithdraw = () => {
    if (withdrawAmount > 0 && withdrawAmount <= satoshis) {
      setSatoshis(prev => prev - withdrawAmount)
      onClose()
      addNotification('transaction', 'Withdrawal Successful', `You have withdrawn ${withdrawAmount} satoshis.`)
    }
  }

  const handleSwap = () => {
    const maxSwapAmount = Math.floor(satoshis / SATOSHI_TO_SNOW_RATE)
    if (maxSwapAmount > 0) {
      const swapAmount = maxSwapAmount * SATOSHI_TO_SNOW_RATE
      setSatoshis(prev => prev - swapAmount)
      setSnowCoins(prev => prev + maxSwapAmount)
      onClose()
      addNotification('transaction', 'Swap Successful', `You have swapped ${swapAmount} satoshis for ${maxSwapAmount} Snow Tokens.`)
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Withdraw or Swap</DialogTitle>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <label htmlFor="withdraw-amount" className="text-right">
              Withdraw Amount
            </label>
            <input
              id="withdraw-amount"
              type="number"
              className="col-span-3 bg-slate-800 text-white p-2 rounded"
              value={withdrawAmount}
              onChange={(e) => setWithdrawAmount(Number(e.target.value))}
              max={satoshis}
            />
          </div>
        </div>
        <DialogFooter>
          <Button onClick={onClose}>Cancel</Button>
          <Button onClick={handleWithdraw} disabled={withdrawAmount <= 0 || withdrawAmount > satoshis}>
            Withdraw Satoshis
          </Button>
          <Button onClick={handleSwap} disabled={satoshis < SATOSHI_TO_SNOW_RATE}>
            Swap All for Snow Tokens
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

interface ShareModalProps {
  isOpen: boolean;
  onClose: () => void;
  onShare: () => void;
  onDownload: () => void;
}

const ShareModal: React.FC<ShareModalProps> = ({ isOpen, onClose, onShare, onDownload }) => {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Share or Download Stream</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <p className="text-sm text-gray-400">
            Your stream will include a logo watermark for branding and protection.
          </p>
          <div className="flex justify-center space-x-4 py-4">
            <Button onClick={() => { onShare(); onClose(); }}>
              <Share2 className="w-4 h-4 mr-2" />
              Share Stream
            </Button>
            <Button onClick={() => { onDownload(); onClose(); }}>
              <Download className="w-4 h-4 mr-2" />
              Download Stream
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

// Placeholder for SendTokensModal -  You'll need to implement this component
const SendTokensModal: React.FC<{ isOpen: boolean; onClose: () => void }> = ({ isOpen, onClose }) => {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Send Tokens</DialogTitle>
        </DialogHeader>
        <p>Send Tokens Modal Content</p>
        <DialogFooter>
          <Button onClick={onClose}>Close</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

