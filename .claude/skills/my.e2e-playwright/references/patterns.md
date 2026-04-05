# Playwright コードパターン（参照用）

長いサンプルは `SKILL.md` から分離。実装時に必要な節だけ読む。

## Page Object Model（POM）

```typescript
import { Page, Locator } from '@playwright/test';

export class ExampleListPage {
  readonly page: Page;
  readonly searchInput: Locator;
  readonly itemRows: Locator;

  constructor(page: Page) {
    this.page = page;
    this.searchInput = page.getByTestId('search-input');
    this.itemRows = page.getByTestId('item-row');
  }

  async goto() {
    await this.page.goto('/items');
    await this.page.waitForLoadState('domcontentloaded');
  }

  async search(query: string) {
    await this.searchInput.fill(query);
    await this.page.waitForResponse((r) => r.url().includes('/api/search') && r.status() === 200);
  }

  async countItems() {
    return this.itemRows.count();
  }
}
```

## スペック例

```typescript
import { test, expect } from '@playwright/test';
import { ExampleListPage } from '../pages/ExampleListPage';

test.describe('一覧と検索', () => {
  test('キーワードで絞り込める', async ({ page }) => {
    const list = new ExampleListPage(page);
    await list.goto();
    await list.search('alpha');
    expect(await list.countItems()).toBeGreaterThan(0);
    await expect(list.itemRows.first()).toContainText(/alpha/i);
  });
});
```

## playwright.config.ts（例）

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['junit', { outputFile: 'playwright-results.xml' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

## フレイキー隔離の例

```typescript
test('不安定なフロー', async () => {
  test.fixme(true, 'Issue #123 で追跡中');
});

test('CI のみスキップ', async () => {
  test.skip(!!process.env.CI, 'CI で不安定 Issue #456');
});
```

## GitHub Actions 抜粋

```yaml
- run: npm ci
- run: npx playwright install --with-deps
- run: npx playwright test
  env:
    BASE_URL: ${{ vars.STAGING_URL }}
- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
```

アクションのバージョンや Node セットアップはリポジトリの方針に合わせて更新すること。CI 全体のレビューは `/my:review-config` を使う。
