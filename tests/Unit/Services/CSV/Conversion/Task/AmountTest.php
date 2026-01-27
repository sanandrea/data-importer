<?php

/*
 * AmountTest.php
 * Copyright (c) 2025 james@firefly-iii.org
 *
 * This file is part of Firefly III (https://github.com/firefly-iii).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

declare(strict_types=1);

namespace Tests\Unit\Services\CSV\Conversion\Task;

use App\Services\CSV\Conversion\Task\Amount as AmountTask;
use Tests\TestCase;

/**
 * Lightweight tests for amount summing behavior.
 *
 * @internal
 *
 * @coversNothing
 */
final class AmountTest extends TestCase
{
    /**
     * Test single amount (backward compatibility).
     */
    public function testSingleAmount(): void
    {
        $task = new AmountTask();
        $result = $task->process([
            'transactions' => [[
                'amount' => '-100',
                'amount_debit' => null,
                'amount_credit' => null,
                'amount_negated' => null,
                'amount_modifier' => '1',
            ]]
        ]);

        $this->assertSame('-100.000000000000', $result['transactions'][0]['amount']);
        $this->assertSame('withdrawal', $result['transactions'][0]['type']);
    }

    /**
     * Test amount + fee (primary use case).
     */
    public function testAmountPlusFee(): void
    {
        $task = new AmountTask();
        $result = $task->process([
            'transactions' => [[
                'amount' => '-100',
                'amount_debit' => null,
                'amount_credit' => null,
                'amount_negated' => '-5',
                'amount_modifier' => '1',
            ]]
        ]);

        $this->assertSame('-105.000000000000', $result['transactions'][0]['amount']);
    }

    /**
     * Test summing multiple amount fields.
     */
    public function testMultipleFields(): void
    {
        $task = new AmountTask();
        $result = $task->process([
            'transactions' => [[
                'amount' => '-100',
                'amount_debit' => '-20',
                'amount_credit' => null,
                'amount_negated' => '-5',
                'amount_modifier' => '1',
            ]]
        ]);

        $this->assertSame('-125.000000000000', $result['transactions'][0]['amount']);
    }

    /**
     * Test with amount modifier.
     */
    public function testWithModifier(): void
    {
        $task = new AmountTask();
        $result = $task->process([
            'transactions' => [[
                'amount' => '-100',
                'amount_debit' => null,
                'amount_credit' => null,
                'amount_negated' => '-5',
                'amount_modifier' => '-1',
            ]]
        ]);

        $this->assertSame('105.000000000000', $result['transactions'][0]['amount']);
        $this->assertSame('deposit', $result['transactions'][0]['type']);
    }

    /**
     * Test zero amounts are ignored.
     */
    public function testZeroIgnored(): void
    {
        $task = new AmountTask();
        $result = $task->process([
            'transactions' => [[
                'amount' => '0',
                'amount_debit' => null,
                'amount_credit' => null,
                'amount_negated' => '-5',
                'amount_modifier' => '1',
            ]]
        ]);

        $this->assertSame('-5.000000000000', $result['transactions'][0]['amount']);
    }
}
