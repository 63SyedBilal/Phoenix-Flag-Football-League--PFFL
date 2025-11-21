"use client"

import { Search, Edit, Trash2 } from "lucide-react"

export default function UsersPage() {
  const users = [
    { id: 1, name: "John Carter", email: "john@example.com", role: "Captain", status: "Active" },
    { id: 2, name: "Sarah Johnson", email: "sarah@example.com", role: "Player", status: "Active" },
    { id: 3, name: "Michael Lee", email: "michael@example.com", role: "Referee", status: "Inactive" },
    { id: 4, name: "Rebecca Torres", email: "rebecca@example.com", role: "Stat Keeper", status: "Active" },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-foreground">Users</h1>
        <p className="text-muted-foreground mt-1">Manage all registered users in the system</p>
      </div>

      {/* Search and Filter */}
      <div className="flex items-center gap-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by name or email..."
            className="w-full pl-10 pr-4 py-2 border border-border rounded-lg bg-card text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-card border border-border rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border">
                <th className="px-6 py-3 text-left text-sm font-medium text-muted-foreground">Name</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-muted-foreground">Email</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-muted-foreground">Role</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-muted-foreground">Status</th>
                <th className="px-6 py-3 text-left text-sm font-medium text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} className="border-b border-border last:border-b-0 hover:bg-muted transition-colors">
                  <td className="px-6 py-3 font-medium text-foreground">{user.name}</td>
                  <td className="px-6 py-3 text-muted-foreground">{user.email}</td>
                  <td className="px-6 py-3">
                    <span className="px-3 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary">
                      {user.role}
                    </span>
                  </td>
                  <td className="px-6 py-3">
                    <span
                      className={`px-3 py-1 rounded-full text-xs font-medium ${
                        user.status === "Active" ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-700"
                      }`}
                    >
                      {user.status}
                    </span>
                  </td>
                  <td className="px-6 py-3">
                    <div className="flex items-center gap-2">
                      <button className="p-2 hover:bg-muted-foreground/10 rounded transition-colors">
                        <Edit className="w-4 h-4 text-muted-foreground" />
                      </button>
                      <button className="p-2 hover:bg-red-100 rounded transition-colors">
                        <Trash2 className="w-4 h-4 text-red-600" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
