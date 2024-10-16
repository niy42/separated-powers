"use client"

import { useState } from 'react'
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { AlertCircle, CheckCircle2, XCircle, FileText, UserCircle, Shield, Activity } from "lucide-react"
import { ScrollArea } from "@/components/ui/scroll-area"

type Decision = {
    id: number
    title: string
    description: string
    status: 'proposed' | 'approved' | 'rejected' | 'executed'
}

export default function DAOGovernance() {
    const [decisions, setDecisions] = useState<Decision[]>([])
    const [newDecision, setNewDecision] = useState({ title: '', description: '' })

    const proposeDecision = () => {
        if (newDecision.title && newDecision.description) {
            setDecisions([...decisions, {
                id: decisions.length + 1,
                ...newDecision,
                status: 'proposed'
            }])
            setNewDecision({ title: '', description: '' })
        }
    }

    const updateDecisionStatus = (id: number, status: Decision['status']) => {
        setDecisions(decisions.map(decision =>
            decision.id === id ? { ...decision, status } : decision
        ))
    }

    return (
        <div className="container mx-auto p-4 space-y-8">
            <header className="text-center mb-8">
                <h1 className="text-4xl font-bold mb-2">DAO Governance System</h1>
                <p className="text-xl text-muted-foreground">Empowering decentralized decision-making</p>
            </header>

            <Tabs defaultValue="propose" className="mb-6">
                <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="propose" className="text-lg">
                        <UserCircle className="mr-2 h-5 w-5" />
                        Role A: Propose
                    </TabsTrigger>
                    <TabsTrigger value="approve" className="text-lg">
                        <Shield className="mr-2 h-5 w-5" />
                        Role B: Approve & Execute
                    </TabsTrigger>
                </TabsList>

                <TabsContent value="propose">
                    <Card className="border-t-4 border-t-blue-500">
                        <CardHeader>
                            <CardTitle className="text-2xl flex items-center">
                                <FileText className="mr-2 h-6 w-6 text-blue-500" />
                                Propose a New Decision
                            </CardTitle>
                            <CardDescription>As Role A, you can propose new decisions for the DAO</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div>
                                <Label htmlFor="title" className="text-lg">Decision Title</Label>
                                <Input
                                    id="title"
                                    value={newDecision.title}
                                    onChange={(e) => setNewDecision({ ...newDecision, title: e.target.value })}
                                    placeholder="Enter a concise title for your decision"
                                    className="mt-1"
                                />
                            </div>
                            <div>
                                <Label htmlFor="description" className="text-lg">Decision Description</Label>
                                <Textarea
                                    id="description"
                                    value={newDecision.description}
                                    onChange={(e) => setNewDecision({ ...newDecision, description: e.target.value })}
                                    placeholder="Provide a detailed description of the proposed decision"
                                    className="mt-1"
                                    rows={4}
                                />
                            </div>
                        </CardContent>
                        <CardFooter>
                            <Button onClick={proposeDecision} className="w-full">
                                <FileText className="mr-2 h-4 w-4" />
                                Propose Decision
                            </Button>
                        </CardFooter>
                    </Card>
                </TabsContent>

                <TabsContent value="approve">
                    <Card className="border-t-4 border-t-green-500">
                        <CardHeader>
                            <CardTitle className="text-2xl flex items-center">
                                <Activity className="mr-2 h-6 w-6 text-green-500" />
                                Approve and Execute Decisions
                            </CardTitle>
                            <CardDescription>As Role B, you can approve, reject, or execute proposed decisions</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <ScrollArea className="h-[400px] pr-4">
                                {decisions.length === 0 ? (
                                    <p className="text-center text-muted-foreground">No decisions have been proposed yet.</p>
                                ) : (
                                    <ul className="space-y-4">
                                        {decisions.map(decision => (
                                            <li key={decision.id} className="border p-4 rounded-md shadow-sm hover:shadow-md transition-shadow">
                                                <h3 className="font-semibold text-lg">{decision.title}</h3>
                                                <p className="text-sm text-muted-foreground mb-2">{decision.description}</p>
                                                <div className="flex items-center justify-between">
                                                    <Badge variant={
                                                        decision.status === 'proposed' ? 'default' :
                                                            decision.status === 'approved' ? 'secondary' :
                                                                decision.status === 'rejected' ? 'destructive' : 'outline'
                                                    } className="text-sm">
                                                        {decision.status.charAt(0).toUpperCase() + decision.status.slice(1)}
                                                    </Badge>
                                                    {decision.status === 'proposed' && (
                                                        <div className="space-x-2">
                                                            <Button size="sm" variant="outline" className="border-green-500 text-green-500 hover:bg-green-50" onClick={() => updateDecisionStatus(decision.id, 'approved')}>
                                                                <CheckCircle2 className="mr-1 h-4 w-4" /> Approve
                                                            </Button>
                                                            <Button size="sm" variant="outline" className="border-red-500 text-red-500 hover:bg-red-50" onClick={() => updateDecisionStatus(decision.id, 'rejected')}>
                                                                <XCircle className="mr-1 h-4 w-4" /> Reject
                                                            </Button>
                                                        </div>
                                                    )}
                                                    {decision.status === 'approved' && (
                                                        <Button size="sm" variant="outline" className="border-blue-500 text-blue-500 hover:bg-blue-50" onClick={() => updateDecisionStatus(decision.id, 'executed')}>
                                                            <AlertCircle className="mr-1 h-4 w-4" /> Execute
                                                        </Button>
                                                    )}
                                                </div>
                                            </li>
                                        ))}
                                    </ul>
                                )}
                            </ScrollArea>
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>

            <Card className="border-t-4 border-t-purple-500">
                <CardHeader>
                    <CardTitle className="text-2xl flex items-center">
                        <Shield className="mr-2 h-6 w-6 text-purple-500" />
                        Governance System Overview
                    </CardTitle>
                </CardHeader>
                <CardContent className="grid md:grid-cols-2 gap-6">
                    <div>
                        <h3 className="font-semibold text-lg mb-2 flex items-center">
                            <UserCircle className="mr-2 h-5 w-5 text-blue-500" />
                            Role A: Proposers
                        </h3>
                        <ul className="list-disc list-inside space-y-1 text-muted-foreground">
                            <li>Can propose new decisions for the DAO</li>
                            <li>Cannot approve or execute decisions</li>
                        </ul>
                    </div>

                    <div>
                        <h3 className="font-semibold text-lg mb-2 flex items-center">
                            <Shield className="mr-2 h-5 w-5 text-green-500" />
                            Role B: Approvers & Executors
                        </h3>
                        <ul className="list-disc list-inside space-y-1 text-muted-foreground">
                            <li>Can approve or reject proposed decisions</li>
                            <li>Can execute approved decisions</li>
                            <li>Cannot propose new decisions</li>
                        </ul>
                    </div>

                    <div className="md:col-span-2">
                        <h3 className="font-semibold text-lg mb-2 flex items-center">
                            <Activity className="mr-2 h-5 w-5 text-purple-500" />
                            Checks and Balances
                        </h3>
                        <ul className="list-disc list-inside space-y-1 text-muted-foreground">
                            <li>Separation of proposal and approval powers</li>
                            <li>Two-step process: approval then execution</li>
                            <li>Transparent decision history and status tracking</li>
                        </ul>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}