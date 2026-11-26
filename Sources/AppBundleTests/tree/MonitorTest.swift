@testable import AppBundle
import Common
import Testing

@MainActor
@Suite(.serializedGlobally)
struct MonitorTest {
    init() { setUpWorkspacesForTests() }

    // E.g. the built-in display is replaced by an external display in clamshell mode. Monitor count and top-left corner
    // stay the same, but the monitor rect changes. Stale rect makes AeroSpace "hide" windows in a visible part of the screen
    @Test func testMonitorReplacedAtTheSamePoint() {
        let focusedWorkspace = globalFocus.workspace
        let invisibleWorkspace = Workspace.get(byName: "a")
        TestWindow.new(id: 1, parent: invisibleWorkspace.floatingWindowsContainer)
        assertEquals(focusedWorkspace.workspaceMonitorInfo.rect.width, 1920)

        let builtIn = Rect(topLeftX: 0, topLeftY: 0, width: 1800, height: 1169)
        monitorInfosForTests = [testMonitorInfo(name: "Built-in Retina Display", rect: builtIn)]
        gcMonitors()
        assertEquals(focusedWorkspace.workspaceMonitorInfo.name, "Built-in Retina Display")
        assertEquals(invisibleWorkspace.workspaceMonitorInfo.rect.width, 1800)

        let external = Rect(topLeftX: 0, topLeftY: 0, width: 3840, height: 2160)
        monitorInfosForTests = [testMonitorInfo(name: "LG Ultra HD", rect: external)]
        gcMonitors()
        assertEquals(focusedWorkspace.workspaceMonitorInfo.name, "LG Ultra HD")
        assertEquals(invisibleWorkspace.workspaceMonitorInfo.rect.width, 3840)
        assertEquals(invisibleWorkspace.workspaceMonitorInfo.visibleRect.height, 2160)

        // Workspaces stay where they were
        assertTrue(focusedWorkspace.isVisible)
        assertFalse(invisibleWorkspace.isVisible)
        assertEquals(Monitor.all.count, 1)
    }

    @Test func testVisibleRectChange() { // E.g. the Dock is moved or starts auto-hiding
        let rect = Rect(topLeftX: 0, topLeftY: 0, width: 1920, height: 1080)
        monitorInfosForTests = [testMonitorInfo(name: "Test Monitor", rect: rect, visibleRect: Rect(topLeftX: 0, topLeftY: 25, width: 1920, height: 1000))]
        gcMonitors()
        assertEquals(globalFocus.workspace.workspaceMonitorInfo.visibleRect.height, 1000)
    }
}
